resource "aws_eip" "bastion_eip" {
  count    = var.bastion_enabled && var.bastion_eip_enabled ? 1 : 0
  instance = aws_instance.bastion.0.id
  vpc      = true
  tags     = local.tags
}

resource "aws_cloudwatch_metric_alarm" "bastion_cpu_threshold" {
  count = var.bastion_enabled ? 1 : 0

  alarm_name                = "${var.environment_name}-bastion-cpu-threshold"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []

  dimensions = {
    InstanceId = aws_instance.bastion[0].id
  }

  tags = local.tags
}

resource "aws_security_group" "bastion" {
  name        = "${var.environment_name}-bastion"
  description = "Security group for bastion"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    "Name"                = "${var.environment_name}-bastion"
    "KubespotEnvironment" = var.environment_name
  })
}

resource "aws_security_group_rule" "bastion_ssh" {
  for_each          = toset(var.bastion_vpn_allowed_cidrs)
  cidr_blocks       = [each.key]
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.bastion.id
  to_port           = 22
  type              = "ingress"
}

resource "aws_instance" "bastion" {
  count = var.bastion_enabled ? 1 : 0

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.bastion_instance_type

  key_name                    = var.bastion_ec2_keypair
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.node.id, aws_security_group.bastion.id]

  monitoring = true

  tags = merge(local.tags, {
    "Name"                = "${var.environment_name}-bastion"
    "KubespotEnvironment" = var.environment_name
  })
  user_data = <<SCRIPT
#!/bin/bash

#wget -q -O - https://updates.atomicorp.com/installers/atomic | bash
apt-get update -y
apt-get install -y python-minimal python-urllib3

if [[ "${var.foxpass_install}" = "" ]]
then
    echo "Not Installing Foxpass"
else
    wget https://raw.githubusercontent.com/abhiyerra/foxpass-setup/master/linux/ubuntu/18.04/foxpass_setup.py
    python foxpass_setup.py --base-dn ${var.foxpass_base_dn}  --bind-user ${var.foxpass_bind_user} --bind-pw ${var.foxpass_bind_pw} --api-key ${var.foxpass_api_key}
fi

${var.instance_userdata}

echo 'echo "Ciphers aes128-ctr,aes192-ctr,aes256-ctr" | tee -a /etc/ssh/sshd_config' | tee -a /etc/rc.local
echo 'echo "MACs hmac-sha1,hmac-sha2-256,hmac-sha2-512" | tee -a /etc/ssh/sshd_config' | tee -a /etc/rc.local
echo 'systemctl reload ssh.service' | tee -a /etc/rc.local
echo 'exit 0' | tee -a /etc/rc.local
chmod +x /etc/rc.local
SCRIPT

  root_block_device {
    encrypted   = true
    volume_size = var.bastion_volume_size
  }
}

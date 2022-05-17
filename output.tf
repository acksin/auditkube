output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "public_route_table" {
  value = aws_route_table.public.*.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.gw.id
}

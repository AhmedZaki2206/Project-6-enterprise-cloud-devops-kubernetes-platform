output "vpc_id" { value = aws_vpc.this.id }
output "public_subnet_ids" { value = aws_subnet.public[*].id }
output "private_subnet_ids" { value = aws_subnet.private[*].id }
output "public_route_table_id" { value = aws_route_table.public.id }
output "private_route_table_ids" { value = aws_route_table.private[*].id }
output "application_security_group_id" { value = aws_security_group.application.id }

output "public_subnets_ids" {
  value = [for o in aws_subnet.public_subnet : o.id]
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

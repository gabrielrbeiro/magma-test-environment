variable "cidr_block" {
  type = string
}

variable "public_subnets" {
  type = list(object({
    cidr_block = string
    zone       = string
    name       = string
  }))
}

variable "name" {
  type = string
}

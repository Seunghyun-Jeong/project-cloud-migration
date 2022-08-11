# resource "aws_vpc" "example" {
#   cidr_block = "10.0.0.0/16"
# }

# resource "aws_service_discovery_private_dns_namespace" "namespace" {
#   name        = "Private"
#   description = "namespace-user"
#   vpc         = aws_vpc.vpc.id
# }

# resource "aws_service_discovery_service" "namespace-service" {
#   name = "Information"

#   dns_config {
#     namespace_id = aws_service_discovery_private_dns_namespace.namespace.id

#     dns_records {
#       ttl  = 300
#       type = "A"
#     }

#     routing_policy = "WEIGHTED"
#   }
# }

# resource "aws_service_discovery_instance" "ns-service-instance" {
#   instance_id = "Private-EC2"
#   service_id  = aws_service_discovery_service.namespace-service.id

#   attributes = {
#     AWS_INSTANCE_IPV4 = aws_instance.USEREC202.private_ip
#     custom_attribute  = "custom"
#   }
# }

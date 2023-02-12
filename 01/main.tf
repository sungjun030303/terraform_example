# 책의 예제는 "us-east-2" 리전 사용
# 저희는 "ap-northeast-2", 서울리전을 사용하여 진행합니다.

terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

# resource 작성 규칙
#
# resource "<PROVIDER>_<TYPE>" "<NAME>" {
#     [CONFIG ...]
# }
# $PROVIDER :공급자 이름
# TYPE 리소스 유형.
# NAME 은 별칭 식별자로 보면 됨.

# 별다른 옵션 없이 작성 후, 실행하면 default vpc의 랜덤한 서브넷에 퍼블릭 (유동) IP 달고 (대충 그냥) 생성됩니다.

# resource "aws_instance" "TEST-Server" {
#     ami = "ami-0bd0b402e20c0c1a1"
#     instance_type = "t2.micro"
# }
resource "aws_instance" "example" {
  ami                    = "ami-0bd0b402e20c0c1a1"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  user_data_replace_on_change = true

  tags = {
    Name = "terraform-example"
  }
}

resource "aws_security_group" "instance" {

  name = var.security_group_name

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "terraform-example-instance"
}

output "public_ip" {
  value       = aws_instance.example.public_ip
  description = "The public IP of the Instance"
}




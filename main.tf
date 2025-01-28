module "jenkins" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins"

  instance_type          = "t2.micro"
  vpc_security_group_ids = ["sg-09fb2be845ba7fc96"]
  subnet_id              = "subnet-079e52471e1c2d1ef"
  ami = data.aws_ami.ami_id.id
  user_data = file("jenkins.sh")
  tags = {
    Name = "Jenkins"
  }
  # Define the root volume size and type
  root_block_device = [
    {
        volume_size = 50       # Size of the root volume in GB
        volume_type = "gp3"    # General Purpose SSD (you can change it if needed)
        delete_on_termination = true  # Automatically delete the volume when the instance is terminated
    }
  ]
}
module "jenkins-agent" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-agent"

  instance_type          = "t2.micro"
  vpc_security_group_ids = ["sg-09fb2be845ba7fc96"]
  subnet_id              = "subnet-079e52471e1c2d1ef"
  ami = data.aws_ami.ami_id.id
  user_data = file("jenkins-agent.sh")
  tags = {
    Name = "Jenkins-Agent"
  }
  # Define the root volume size and type
  root_block_device = [
    {
        volume_size = 50       # Size of the root volume in GB
        volume_type = "gp3"    # General Purpose SSD (you can change it if needed)
        delete_on_termination = true  # Automatically delete the volume when the instance is terminated
    }
  ]
}
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 3.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "jenkins"
      type    = "A"
      ttl = 1
      records = [
        module.jenkins.public_ip
      ]
      allow_overwrite = true
    },
    {
      name    = "jenkins-agent"
      type    = "A"
      ttl = 1
      records = [
        module.jenkins-agent.private_ip
      ]
      allow_overwrite = true
    },
  ]
}
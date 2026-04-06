data "aws_elastic_beanstalk_solution_stack" "docker" {
  most_recent = true
  name_regex  = "^64bit Amazon Linux 2 v.* running Docker.*"
}

resource "aws_elastic_beanstalk_application" "app" {
  name = "chatapp-frontend"
}

data "aws_iam_instance_profile" "lab_profile" {
  name = "LabInstanceProfile"
}

resource "aws_elastic_beanstalk_environment" "env" {
  name                = "chatapp-frontend-env"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.docker.name

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = data.aws_iam_instance_profile.lab_profile.name
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = var.public_subnet_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "true"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = var.sg_id
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "BACKEND_URL"
    value     = "http://${var.backend_url}"
  }
}

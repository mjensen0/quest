# Create ALB
resource "aws_lb" "quest" {
  name               = "quest-elb"
  load_balancer_type = "application"
  security_groups    = [
    module.ec2_sg.security_group_id
  ]
  subnets            = [for id in data.aws_subnets.all.ids : id]
  internal = false
}
# Create Target Group for EC2 instance
resource "aws_lb_target_group" "quest" {
    name = "quest-lb-tg"
    port = 80
    protocol = "HTTP"
    vpc_id= data.aws_vpc.default.id
    #Set health check for TG, due to slow load of node app timeout is set high
    health_check {
        healthy_threshold = 2
        interval = 30
        matcher = "200"
        path = "/"
        timeout = 25
        unhealthy_threshold = 5
    }
}

#Direct port 80 to TG from ALB
resource "aws_lb_listener" "quest" {
    load_balancer_arn = aws_lb.quest.arn
    port = "80"
    protocol = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.quest.arn
    }
}

#Direct port 443 to TG from ALB and Bind certificate
resource "aws_lb_listener" "quest-https" {
    load_balancer_arn = aws_lb.quest.arn
    port = 443
    protocol = "HTTPS"
    certificate_arn = aws_acm_certificate_validation.quest.certificate_arn
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.quest.arn
    }
}

#Attach EC2 instance to TG
resource "aws_lb_target_group_attachment" "quest" {
  target_group_arn = aws_lb_target_group.quest.arn
  target_id        = aws_instance.web.id
  port             = 80
}

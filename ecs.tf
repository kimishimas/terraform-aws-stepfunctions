resource "aws_ecs_task_definition" "task" {
  family                   = "helloworld-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./container_definitions.json")
}

resource "aws_ecs_cluster" "cluster" {
  name = "helloworld-cluster"
}

resource "aws_ecs_service" "service" {
  name             = "helloworld-service"
  cluster          = aws_ecs_cluster.cluster.arn
  task_definition  = aws_ecs_task_definition.task.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.4.0"
  network_configuration {
    assign_public_ip = true
    security_groups  = [module.sg.security_group_id]
    subnets          = module.vpc.public_subnets
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}


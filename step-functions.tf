
locals {
  subnets_id = jsonencode("${module.vpc.public_subnets}")
}

module "stepfunctions" {
  source = "terraform-aws-modules/step-functions/aws"
  name   = "step-functions"

  #role_arn = aws_iam_role.step-functions.arn
  attach_policy_statements = true
  policy_statements = {
    cloudwatch = {
      effect    = "Allow",
      actions   = ["events:PutTargets", "events:PutRule", "events:DescribeRule"],
      resources = ["*"]
    },
    ecs = {
      effect    = "Allow",
      actions   = ["ecs:RunTask"]
      resources = ["*"]
    }
  }


  definition = <<EOF
{
  "Comment": "A Hello World example of the Amazon States Language using an AWS Lambda Function",
  "StartAt": "HelloWorld",
  "States": {
    "HelloWorld": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "End": true,
      "TimeoutSeconds": 300,
      "Parameters": {
        "LaunchType": "FARGATE",
        "Cluster": "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${resource.aws_ecs_cluster.cluster.name}",
        "TaskDefinition": "${resource.aws_ecs_task_definition.task.arn}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "Subnets": ${local.subnets_id},
            "SecurityGroups": [
              "${module.sg.security_group_id}"
            ],
            "AssignPublicIp": "ENABLED"
          }
        }
      }
    }
  }
}
EOF

  type = "STANDARD"

}

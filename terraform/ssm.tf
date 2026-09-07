resource "aws_iam_role_policy_attachment" "ssm" {
  role       = "ECRPullPolicy"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_codestarconnections_connection" "this" {
  name          = var.connection_name != null ? var.connection_name : "${var.project_name}-github"
  provider_type = var.provider_type
  tags          = var.tags
}

# Test variables for ZPA Security Group module
name_prefix  = "test-sg"
resource_tag = "terratest"
global_tags = {
  Environment = "test"
  Purpose     = "terratest"
  Owner       = "zscaler"
}

resource "kubernetes_storage_class" "ebs_sc" {
  metadata {
    name = "ebs-sc"
  }

  storage_provisioner = "ebs.csi.aws.com"

  parameters = {
    type      = "gp3"
    fsType    = "ext4"
     # TODO: encrypt

  }

  volume_binding_mode = "WaitForFirstConsumer"
}

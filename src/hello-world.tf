resource "null_resource" "hello-world" {
  provisioner "local-exec" {
    command = "echo Hello World!"
  }
}

output "elb_address" {
  value = "${aws_elb.elb-web-np.dns_name}"
}

output "web01_np_public_dns" {
   value = "${aws_instance.web01_np.public_dns}"
}

output "web01_np_public_ip" {
   value = "${aws_instance.web01_np.public_ip}"
}

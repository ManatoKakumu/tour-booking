resource "aws_nat_gateway" "main" {
  vpc_id            = aws_vpc.main.id
  availability_mode = "regional"

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "tour-booking-nat"
  }
}

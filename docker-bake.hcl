target "default" {
    platforms = [
        "linux/amd64",
        "linux/arm64"
    ]
    tags = [
        "quay.io/inviqa_images/chromium:latest"
    ]
}

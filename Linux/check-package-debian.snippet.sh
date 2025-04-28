# Check for required packages
check_package() {
    dpkg -s "$1" &> /dev/null || {
        echo "Error: Required package '$1' is not installed."
        echo "Install with: sudo apt install $1"
        exit 1
    }
}

# usage in script
check_package <package name>

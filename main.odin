package main

import "core:slice"
import "core:fmt"
import "core:net"
import "core:os"
import "core:strconv"

main :: proc() {
	if slice.contains(os.args, "--help") || slice.contains(os.args, "-h") {
		print_help()
		return
	}

	hostname := "127.0.0.1"
	range_start := 1
	range_end := 65535

	if len(os.args) < 1 || len(os.args) > 4 {
		print_help()
		return
	}

	switch len(os.args) {
	case 4:
		ok: bool

		range_end, ok = strconv.parse_int(os.args[3], 10, nil)
		if !ok {
			fmt.eprintfln("Invalid range_end: '%s'", os.args[3])
			return
		}
		fallthrough
	case 3:
		ok: bool

		range_start, ok = strconv.parse_int(os.args[2], 10, nil)
		if !ok {
			fmt.eprintfln("Invalid range_start: '%s'", os.args[2])
			return
		}
		fallthrough
	case 2:
		hostname = os.args[1]
		if hostname == "localhost" {
			hostname = "127.0.0.1"
		}
	}

	address, ok := net.parse_ip4_address(hostname)
	if !ok {
		fmt.eprintfln("Invalid host: '%s'", hostname)
		return
	}

	if range_start < 1 || range_end > 65535 || range_start > range_end {
		fmt.eprintln("Invalid port range")
		return
	}

	endpoint := net.Endpoint {
		address = address,
	}

	for port := range_start; port <= range_end; port += 1 {
		endpoint.port = port
		s, err := net.dial_tcp_from_endpoint(endpoint)
		if err == nil {
			fmt.println(port)
			net.close(s)
		}
	}
}

print_help :: proc() {
	fmt.println("Usage: ports [HOST] [RANGE_START] [RANGE_END]")
	fmt.println("Check open ports in HOST, optionally specifying a RANGE")
	fmt.println()
	fmt.println("  --help     display this help and exit")
}

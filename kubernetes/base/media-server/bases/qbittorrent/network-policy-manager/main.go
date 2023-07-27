package main

type VPNProvidersList struct {
	Version int `json:"version"`
}

type VPNProvidersListProviders = map[string]VPNProviderServersList

type VPNProviderServersList struct {
	Version   int `json:"version"`
	Timestamp int `json:"timestamp"`
	Servers   []VPNProviderServer
}

type VPNProviderServer struct {
	VPN        string `json:"vpn"`
	Region     string `json:"region"`
	ServerName string `json:"server_name"`
	Hostname   string `json:"hostname"`
	TCP        bool   `json:"tcp"`
	UDP        bool   `json:"udp"`
	IPs        []string
}

func main() {
	// VPN_SERVICE_PROVIDER
	// SERVER_REGIONS
}

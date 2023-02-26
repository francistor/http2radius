package main

import "github.com/francistor/igor/core"

// Sends back the same attributes received in the request
// Prints the received packet
func echoRequestHandler(request *core.RadiusPacket) (*core.RadiusPacket, error) {

	// Initialize logger
	hl := core.NewHandlerLogger()
	l := hl.L

	defer func(l *core.HandlerLogger) {
		l.WriteLog()
	}(hl)

	// Print packet
	l.Infof("received packet %s", request)

	// Compose reply packet
	response := core.NewRadiusResponse(request, true)
	for i := range request.AVPs {
		response.AddAVP(&request.AVPs[i])
	}

	return response, nil
}

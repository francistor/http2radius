package main

import (
	"flag"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/francistor/igor/core"
	"github.com/francistor/igor/httprouter"
	"github.com/francistor/igor/router"
)

func main() {

	// After ^C, signalChan will receive a message
	doneChan := make(chan struct{}, 1)
	signalChan := make(chan os.Signal, 1)
	go func() {
		<-signalChan
		close(doneChan)
		fmt.Println("terminating server")
	}()
	signal.Notify(signalChan, syscall.SIGINT, syscall.SIGTERM)

	// Get the command line arguments
	bootPtr := flag.String("boot", "resources/searchRules.json", "File or http URL with Configuration Search Rules")
	instancePtr := flag.String("instance", "", "Name of instance")

	flag.Parse()

	// Initialize the Config Object
	core.InitPolicyConfigInstance(*bootPtr, *instancePtr, nil, true)

	// Get logger
	logger := core.GetLogger()

	// Start Radius Router
	router := router.NewRadiusRouter(*instancePtr, echoRequestHandler)
	logger.Info("radius router started")

	// Start router
	router.Start()

	// Start http router
	httpRouter := httprouter.NewHttpRouter("", nil, router)

	// Wait for termination signal
	<-doneChan

	// Close routers gracefully
	httpRouter.Close()
	router.Close()
}

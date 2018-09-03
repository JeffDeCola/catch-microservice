package main

import (
	"fmt"
	//"html"
	//"log"
	//"net"
	//"net/http"
	//"os"
	"time"

)

// HelloServer This is a test
// ResponseWriter is the interface
// Request struct that contains data like URL headers body..etc..
//func HelloServer(w http.ResponseWriter, req *http.Request) {
	//io.WriteString(w, "hello, world!\n")
//	fmt.Fprintf(w, "Hello, %q", html.EscapeString(req.URL.Path))
//}

func main() {

	var a = 0

	for {
		a += 1
		fmt.Println("Hello everyone, this is just a placeholder for now:", a)
		time.Sleep(3000 * time.Millisecond)
	}

	// Call this function when you see asdfasdfasdf/hello
	//http.HandleFunc("/hello", HelloServer)
	//http.HandleFunc("/monkey", HelloServer)

	// Starts listening on localhost (127.0.0.1:PORT)
	// log.Fatal(http.ListenAndServe(":8080", nil))
	//log.Fatal(http.ListenAndServe(net.JoinHostPort("127.0.0.1", os.Getenv("myPORT")), nil))


}

#!/usr/local/bin/io

/*
 * SimpleHTTPServer
 * Serves the current directory on specified port
 */

ServiceHandler := Object clone do(

	init := method(
		self dir := ""
	)

	setDir := method(dirpath,
		self dir := dirpath asMutable rstrip("/")
		self
	)

	//processing & serving of a request being at this slot
	process := method(sock, server,
		sock streamReadNextChunk
		buffer := sock readBuffer

		log(buffer split("\n") at(0))
		
		req := buffer betweenSeq("GET","HTTP")

		//ensure only GET's are served 
		if(req !=nil,
			serv(sock,req),
			send405(sock)
		)
		sock close
	)

	serv := method(sock, req,
		f := File with(self getPath(req))
		if( f exists,
			if(f isDirectory,
				self serveDir(sock,req),
				self servFile(sock, f contents)
			),
			send404(sock,req)
		)
	)

	serveDir := method(sock, req,
		dir := Directory with(self getPath(req))

		content := "<html><head> <title> Index of " .. req .. "</title></head><body><h1>Directory listings of " .. req .. "</h1><hr><ul>"
		content = content .. "<li><a href=\"..\">/../</a></li>"
		
		dir directories foreach(directoryElement,
	      content = content .. "<li><a href=\"" .. directoryElement name .. "/\">/" .. directoryElement name .. "/</a></li>"
	    )
	    
	    dir fileNames foreach(fileElement,
	      content = content .. "<li><a href=\"" .. fileElement .. "\">" .. fileElement .. "</a></li>"
	    )
	    content = content .. "</ul><hr></body></html>"

	    sendContent(sock,200,content)
	)

	servFile := method(sock,content,
		sendContent(sock,200,content)
	)

	sendContent := method(sock,respcode, content,
		sock streamWrite(setHeaders(respcode,content))
	)

	send404 := method(sock,req,
		content := "<html><head><title>Not Found !</title></head><body><h1>Resource " .. req exSlice(1) .. " Not Found</h1><body></html>"
		
		sock streamWrite(setHeaders(404,content))
	)

	send405 := method(sock,
		content := "<html><head><title>Not Allowed !</title></head><body><h1>Method Not allowed</h1><body></html>"
		sock streamWrite(setHeaders(405,content))
	)

	setHeaders := method(respcode, data,
	    length := data sizeInBytes
	    code := "\nHTTP/1.1 "
		if(respcode == 200,
			code = code .. "200 OK\n"
		)

		if(respcode == 404,
			code = code .. "404 Not Found\n"
		)

		if(respcode == 405,
			code = code .. "405 Method Not Allowed\n"
		)
	    code = code .. "Content-Length: " .. length .. "\n\n"
	    data = code .. data
	    data
	)

	getPath := method(req,
		(self dir .. req exSlice(1)) asMutable rstrip()
	)

	log := method(message, writeln(message))
)

//Read port and serving Directory from args
port := System args at(1)
workingdir := System args at(2)

writeln("Listening on ", port)
writeln("Serving directory: ",workingdir)

server := Server clone setPort(port asNumber)
server handleSocket := method(sock,
	s := ServiceHandler clone;
	s setDir(workingdir) @process(sock,self)
)

//let the serving begin !
server start
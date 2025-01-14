#include <math.h>
#include <string.h>
#include <WinSock2.h>
#include "mex.h"

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
    double *sock_ret;
    char *ip;
    const mwSize *dims;
    size_t m,n;
    int port;
    
    if (nrhs != 2) 
    { 
	    mexErrMsgIdAndTxt( "MATLAB:ConnectUdp:invalidNumInputs",
                "Two input arguments required."); 
    } 
    else if (nlhs > 1) 
    {
	    mexErrMsgIdAndTxt( "MATLAB:ConnectUdp:maxlhs",
                "Too many output arguments."); 
    } 
    
    // Get the Ip string from the first parameter
    dims = mxGetDimensions(prhs[0]);
    
    ip = mxCalloc(dims[1]+1, sizeof(char));
    mxGetString(prhs[0], ip, dims[1]+1);
    
    // Check if the second parameter is scalar and set the port pointer
    m = mxGetM(prhs[1]); 
    n = mxGetN(prhs[1]);
    
    if(m==1 && n==1)
        port = (int)mxGetPr(prhs[1])[0];
    else
        mexErrMsgIdAndTxt( "MATLAB:UdpConnect:port",
                "Invalid port format(dimensin too big).");
    
    // Set the return pointer to the socket 
    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
    sock_ret = mxGetPr(plhs[0]);
        
    WSADATA wsaData;
    SOCKADDR_IN addr;
    SOCKET sock;
    
    // Win socket initial setup
    WSAStartup(MAKEWORD(2,2), &wsaData);

    // Create socket for UDP and check if it's valid
    sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if(sock == INVALID_SOCKET)
    {
        mexPrintf("Client: socket() failed! Error code: %ld\n", WSAGetLastError());
        WSACleanup();
        return;
    }

    // Connect socket to the host Ip and port specified in the input parameters
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr.s_addr = inet_addr(ip);

    int RetCode = connect(sock, (SOCKADDR *) &addr, sizeof(addr));
    if(RetCode != 0)
    {
        mexPrintf("Client: connect() failed! Error code: %ld\n, WSAGetLastError()");
        closesocket(sock);
        WSACleanup();
        return ;
     }
    
     // If everything is good return the connected socket
     sock_ret[0] = sock;
   
    return;
    
}

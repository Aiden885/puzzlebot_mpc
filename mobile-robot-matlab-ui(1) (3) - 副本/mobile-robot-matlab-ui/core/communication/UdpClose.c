#include <math.h>
#include <string.h>
#include <WinSock2.h>
#include "mex.h"

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{     
    if (nrhs != 1) 
    { 
	    mexErrMsgIdAndTxt( "MATLAB:UdpClose:invalidNumInputs",
                "Two input arguments required."); 
    } 
    else if (nlhs > 0) 
    {
	    mexErrMsgIdAndTxt( "MATLAB:UdpClose:maxlhs",
                "Too many output arguments."); 
    } 

    // Get socket from the first parameter
    SOCKET sock = (int)mxGetPr(prhs[0])[0];

    // Close socket connection
    if(closesocket(sock) != 0)
        mexPrintf("Client: Cannot close socket. Error code: %ld\n", WSAGetLastError());
 
    // release the win socket
    if(WSACleanup() != 0)
        mexPrintf("Client: WSACleanup() failed!...\n");

    return;
    
}

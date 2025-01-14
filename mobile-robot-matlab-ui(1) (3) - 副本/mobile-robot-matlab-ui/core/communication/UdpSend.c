#include <math.h>
#include <string.h>
#include <WinSock2.h>
#include "mex.h"

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
    SOCKET sock;
    char *send_buf;
    int n_bytes = 0;
    int n_block_bytes = 1024;
    
    if (nrhs != 2) { 
	    mexErrMsgIdAndTxt( "MATLAB:UdpSend:invalidNumInputs",
                "Two input arguments required."); 
    } else if (nlhs > 0) {
	    mexErrMsgIdAndTxt( "MATLAB:UdpSend:maxlhs",
                "Too many output arguments."); 
    } 
    
    // Get socket from the first parameter
    sock = (int)mxGetPr(prhs[0])[0];
        
    // Get pointer to send buffer from the second parameter
    n_bytes = mxGetNumberOfElements(prhs[1]);    
    send_buf = (char*)mxGetData(prhs[1]);
         
    // send data buffer and check for errors
    for(int i=0;i<n_bytes;i+=n_block_bytes)
    {
        int ret;
        
        if(i+n_block_bytes<n_bytes)
            ret = send(sock, send_buf+i, n_block_bytes, 0);
        else
            ret = send(sock, send_buf+i, n_bytes-i, 0);
        
        if (ret == SOCKET_ERROR)
        {
           mexPrintf("Send error...\n");
        }
    }
    return;
    
}

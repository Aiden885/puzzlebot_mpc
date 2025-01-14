#include <math.h>
#include <string.h>
#include <WinSock2.h>
#include "mex.h"

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
    SOCKET sock;
    char recv_buf[1048];
    int n_bytes = 0;   
    
    if (nrhs != 1) 
    { 
	    mexErrMsgIdAndTxt( "MATLAB:UdpRceive:invalidNumInputs",
                "Two input arguments required."); 
    } 
    else if (nlhs > 1) 
    {
	    mexErrMsgIdAndTxt( "MATLAB:UdpRceive:maxlhs",
                "Too many output arguments."); 
    } 

    // Get socket from the first parameter
    sock = (int)mxGetPr(prhs[0])[0];
    
    // Check if data is available for reading in the receive buffer. recv() blocks otherwise.
    unsigned long n_available;
    ioctlsocket(sock, FIONREAD, &n_available);
    
    if(n_available>0)
    {
        // Read the available data from socket receive buffer
        int ret = recv(sock, recv_buf, 1048, 0);

        if (ret == SOCKET_ERROR)
        {
           mexPrintf("Receive error...\n");
        }
        else
        {
            // Create return pointer and copy the read data
            plhs[0] = mxCreateNumericMatrix(ret, 1, mxUINT8_CLASS, mxREAL);
            UINT8* pointer = mxGetPr(plhs[0]);

            for (int i = 0; i < ret; i++ )
                pointer[i] = (UINT8)recv_buf[i];
        }
    }
    else
    {
        // Create empty return pointer if nothing is available for reading
        plhs[0] = mxCreateNumericMatrix(0, 0, mxUINT8_CLASS, mxREAL);
    }

    return;
    
}

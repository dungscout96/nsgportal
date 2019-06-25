#include <string.h>
#include <stdlib.h>
#include <curl/curl.h>
#include <mex.h>
#include <curl/curlver.h>
#include <curl/easy.h>

// Define our struct for accepting LCs output
struct BufferStruct
{
	char * buffer;
	size_t size;
};

// This is the function we pass to LC, which writes the output to a BufferStruct
static size_t WriteMemoryCallback(void *ptr, size_t size, size_t nmemb, void *data)
{
	size_t realsize = size * nmemb;

	struct BufferStruct * mem = (struct BufferStruct *) data;
	
	mem->buffer = realloc(mem->buffer, mem->size + realsize + 1);
	
	if ( mem->buffer )
	{
		memcpy( &( mem->buffer[ mem->size ] ), ptr, realsize );
		mem->size += realsize;
		mem->buffer[ mem->size ] = 0;
	}
	return realsize;
}

void libcurlMex() {
	curl_global_init(CURL_GLOBAL_ALL);
	CURL *myHandle = curl_easy_init();
	CURLcode result; // We’ll store the result of CURL’s webpage retrieval
	struct BufferStruct output; // Create an instance of out BufferStruct to accept LCs output
	output.buffer = NULL;
	output.size = 0;
	struct curl_slist *slist=NULL;

	curl_easy_setopt(myHandle, CURLOPT_WRITEFUNCTION, WriteMemoryCallback); // Passing the function pointer to LC
	curl_easy_setopt(myHandle, CURLOPT_WRITEDATA, (void *)&output); // Passing our BufferStruct to LC

	curl_easy_setopt( myHandle, CURLOPT_URL,"https://nsgr.sdsc.edu:8443/cipresrest/v1/job/dt.young112@gmail.com?expand=true");
	curl_easy_setopt( myHandle, CURLOPT_USERPWD, "dt.young112@gmail.com:Thanhyen1996");
	slist = curl_slist_append(slist, "cipres-appkey:TestingEEGLAB-BCE8EC90088F4475AE48190A1B87EF8D");
	curl_easy_setopt( myHandle, CURLOPT_HTTPHEADER, slist);
	result = curl_easy_perform( myHandle ); 
	curl_slist_free_all(slist);
	curl_easy_cleanup( myHandle );

	FILE * fp;
	fp = fopen( "example.xml","w");
	fprintf(fp, output.buffer );
	fclose( fp );

	if( output.buffer )
	{
		free ( output.buffer );
		output.buffer = 0;
		output.size = 0;
	}

	printf("LibCurl rules!\n");
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[]) {
	libcurlMex();
    
    
}


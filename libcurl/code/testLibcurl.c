#include <stdio.h>
#include <stdlib.h>
#include <curl/curl.h>

int main() {
	curl_global_init(CURL_GLOBAL_ALL);
	CURL *myHandle = curl_easy_init();
	CURLcode result; // We’ll store the result of CURL’s webpage retrieval
	struct curl_slist *slist=NULL;

	curl_easy_setopt( myHandle, CURLOPT_URL,"https://nsgr.sdsc.edu:8443/cipresrest/v1/job/dt.young112@gmail.com?expand=true");
	curl_easy_setopt( myHandle, CURLOPT_USERPWD, "dt.young112@gmail.com:Thanhyen1996");
	slist = curl_slist_append(slist, "cipres-appkey:TestingEEGLAB-BCE8EC90088F4475AE48190A1B87EF8D");
	curl_easy_setopt( myHandle, CURLOPT_HTTPHEADER, slist);
	result = curl_easy_perform( myHandle ); 
	curl_slist_free_all(slist);
	curl_easy_cleanup( myHandle );
	
	return 0;
}


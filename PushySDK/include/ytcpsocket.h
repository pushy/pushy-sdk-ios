#ifndef ytcpsocket_h
#define ytcpsocket_h

int ytcpsocket_connect(const char *host, int port, int timeout);
int ytcpsocket_close(int socketfd);
int ytcpsocket_bytes_available(int socketfd);
int ytcpsocket_send(int socketfd, const char *data, int len);
int ytcpsocket_pull(int socketfd, char *data, int len, int timeout_sec);
int ytcpsocket_listen(const char *address, int port);
int ytcpsocket_accept(int onsocketfd, char *remoteip, int *remoteport, int timeouts);
int ytcpsocket_port(int socketfd);

#endif /* ytcpsocket_h */

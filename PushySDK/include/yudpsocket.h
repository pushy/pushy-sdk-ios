#ifndef yudpsocket_h
#define yudpsocket_h

int yudpsocket_server(const char *address, int port);
int yudpsocket_recive(int socket_fd, char *outdata, int expted_len, char *remoteip, int *remoteport);
int yudpsocket_close(int socket_fd);
int yudpsocket_client();
int yudpsocket_get_server_ip(char *host, char *ip);
int yudpsocket_sentto(int socket_fd, char *msg, int len, char *toaddr, int topotr);
void enable_broadcast(int socket_fd);

#endif /* yudpsocket_h */

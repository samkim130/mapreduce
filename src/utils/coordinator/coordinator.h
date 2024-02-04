#include <string>
#include <vector>
#include <cstdlib>

const char *env_default_dir = std::getenv("BASE_SERVER_DIR");

/**
 * Basic Distributed System Coordinator Interface
 *
 */
class Coordinator
{
public:
   Coordinator(std::string &ip_addr, std::string default_dir) : ip_addr(ip_addr), default_dir(default_dir) {}
   Coordinator(std::string &ip_addr) : Coordinator(ip_addr, (env_default_dir ? std::string(env_default_dir) : "/servers")) {}
   // generic path creation
   virtual void registerPath(std::string path) {}
   /** registers itself under default dir
    * returns `true` if node was created `false` otherwise
    */
   virtual bool registerSelf() { return false; }
   virtual void deleteSelfNode() {}
   virtual void closeConnection() { deleteSelfNode(); }
   virtual bool registerNode(const std::string &path, const void *data, const int flag) {}

   // fetches path where the node is registered
   virtual const std::string get_self_path() { return self_path; }
   // fetches data under path
   virtual const void *get_data(const std::string &path) { return (void *)nullptr; }

   const std::string default_dir;
   const std::string ip_addr;

private:
   std::string self_path;
};

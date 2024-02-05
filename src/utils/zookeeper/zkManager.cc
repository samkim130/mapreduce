#include "zkManager.h"

void ZKManager::registerPath(std::string path)
{
   framework->create()->forPath(path);
}

bool ZKManager::registerSelf()
{
   std::string node_path;
   auto node_created = framework
                           ->create()
                           ->withFlags(ZOO_EPHEMERAL_SEQUENTIAL)
                           ->forPath(default_dir + "/server_", ip_addr.c_str(), node_path);
   if (node_created != ZOK)
   {
      LOG(INFO) << "Master candidate failed to connect to Zookeeper. Attempted node: /master/server_# "
                << ". Status: " << node_created << std::endl;
      return false;
   }

   self_path = node_path;
   return true;
}

bool ZKManager::registerNode(const std::string &path, const void *data, const int ZK_FLAG)
{
   const char *stringified_data = (const char *)data;
   int node_created = framework
                          ->create()
                          ->withFlags(ZK_FLAG)
                          ->forPath(path.c_str(), stringified_data);
   if (node_created != ZOK)
   {
      if (node_created == ZNODEEXISTS)
      {
         LOG(INFO) << path << " already exists in Zookeeper" << std::endl;
         // if exists, just update the data
         framework->setData()->forPath(path, stringified_data);
      }
      else
      {
         LOG(INFO) << "Master failed to store job as " << path
                   << " in ZK. Status: " << node_created << std::endl;
         return false;
      }
   }
   return true;
}

std::vector<std::string> ZKManager::get_nodes(const std::string &path)
{
   return framework->getChildren()->forPath(path.c_str());
}

const void *ZKManager::get_data(const std::string &path)
{
   return framework->getData()->forPath(path.c_str()).c_str();
}

void ZKManager::initZK()
{
   framework->start();

   // default path to register nodes under
   registerPath(default_dir);
   registerSelf();
}

void ZKManager::deleteSelfNode()
{
   framework->deleteNode()->deletingChildren()->forPath(self_path);
}

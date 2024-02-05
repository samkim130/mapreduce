#include <string>
#include <memory>
#include <cstdlib>
#include "coordinator.h"
#include <conservator/ConservatorFrameworkFactory.h>
#include <zookeeper/zookeeper.h>
#include <glog/logging.h>

// ref https://www.reddit.com/r/learnprogramming/comments/pdr26m/why_is_it_preferred_to_declare_functions_in/

// "zookeeper.ws1.svc.cluster.local:2181"
const std::string default_zk_server = "zookeeper:2181";

/**
 * Zookeeper Manager class that provides basic functionalities of Zookeeper
 *    - registers the server node
 *    - fetches information
 *    - cleans up after itself
 *
 */
class ZKManager : public Coordinator
{
public:
  inline ZKManager(const std::string &zk_addr, const std::string &ip_addr)
      : zk_addr(zk_addr),
        factory(std::make_unique<ConservatorFrameworkFactory>(ConservatorFrameworkFactory())),
        framework(factory->newClient(zk_addr, 10000000)),
        Coordinator(ip_addr) { initZK(); }
  inline ZKManager(const std::string &zk_addr, const std::string &ip_addr, const std::string &default_dir)
      : zk_addr(zk_addr),
        factory(std::make_unique<ConservatorFrameworkFactory>(ConservatorFrameworkFactory())),
        framework(factory->newClient(zk_addr, 10000000)),
        Coordinator(ip_addr, default_dir) { initZK(); }

  ZKManager(std::string &ip_addr) : ZKManager(default_zk_server, ip_addr) {}

  // generic path creation
  void registerPath(std::string path) override;

  /** registers itself under default dir with `ZOO_EPHEMERAL_SEQUENTIAL` option
   * returns `true` if node was created `false` otherwise
   */
  bool registerSelf() override;
  void deleteSelfNode() override;
  inline void closeConnection() override
  {
    Coordinator::closeConnection();
    framework->close();
  };
  // registers node under given path with the data (expected as `char *`), with optional zookeeper flags
  bool registerNode(const std::string &path, const void *data, const int ZK_FLAG) override;

  // fetches children nodes under the path
  std::vector<std::string> get_nodes(const std::string &path);
  // fetches data under path
  const void *get_data(const std::string &path) override;

protected:
  const std::string zk_addr;
  const std::unique_ptr<ConservatorFrameworkFactory> factory;
  const std::unique_ptr<ConservatorFramework> framework;

private:
  /**
   *
   */
  void initZK();

};

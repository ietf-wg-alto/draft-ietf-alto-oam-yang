# Example Module for Information Resource Creation Algorithm

The base data model defined by ietf-alto.yang does not include any choice cases
for information resource creation algorithms. But developers may augment the
ietf-alto.yang data model with definitions for any custom creation algorithms
for different information resources. The following example module demonstrates
the parameters of a network map creation algorithm that translates an IETF
layer 3 unicast topology into a network map.

~~~
module example-ietf-alto-alg {

  namespace "urn:example:ietf-alto-alg";
  prefix "alto-alg";

  import ietf-alto {
    prefix "alto";
  }

  augment "/alto:alto-server/alto:resource/alto:resource-params"
        + "/alto:networkmap/alto:alto-networkmap-params"
        + "/alto:algorithm" {
    case l3-unicast-cluster {
      container l3-unicast-cluster-algorithm {
        leaf l3-unicast-topo {
          type leafref {
            path "/alto:alto-server/data-source/source-id";
          }
          mandatory true;
          description
            "The data source to an IETF layer 3 unicast topology.";
        }
        leaf depth {
          type uint32;
          description
            "The depth of the clustering.";
        }
      }
    }
  }
}
~~~

<!-- End of sections -->

/*
 * Copyright (c) 2014, Sandia Corporation.
 * Under the terms of Contract DE-AC04-94AL85000 with Sandia Corporation,
 * the U.S. Government retains certain rights in this software.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 * 
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 * 
 *     * Redistributions in binary form must reproduce the above
 *       copyright notice, this list of conditions and the following
 *       disclaimer in the documentation and/or other materials provided
 *       with the distribution.
 * 
 *     * Neither the name of Sandia Corporation nor the names of its
 *       contributors may be used to endorse or promote products derived
 *       from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 */
#ifndef IOCGNS_DECOMPOSITONDATA_H
#define IOCGNS_DECOMPOSITONDATA_H

#if defined(HAVE_MPI)
#include <mpi.h>
#endif

#include <vector>
#include <string>
#include <stddef.h>
#include <stdint.h>

#include <Ioss_CodeTypes.h>
#include <Ioss_PropertyManager.h>

#include <cgnslib.h>

#if 0
#if !defined(NO_PARMETIS_SUPPORT)
#include <parmetis.h>
#endif
#endif

#undef MPICPP
#if !defined(NO_ZOLTAN_SUPPORT)
#include <zoltan_cpp.h>
#endif
namespace Ioss {
  class Field;
}
namespace Iocgns {

  class BlockDecompositionData
  {
  public:
    BlockDecompositionData() :
      zone_(0), section_(0), fileCount(0), iossCount(0), zoneNodeOffset(0),
      nodesPerEntity(0), attributeCount(0), localIossOffset(0)
      {}

      int zone() const {return zone_;}
      int section() const {return section_;}
      
      size_t file_count() const {return fileCount;}
      size_t ioss_count() const {return iossCount;}

      int zone_;
      int section_;
      
      size_t fileCount;
      size_t iossCount;
      size_t zoneNodeOffset;

      std::string topologyType;
      int nodesPerEntity;
      int attributeCount;

      // maps from file-block data to ioss-block data
      // The local_map.size() elements starting at localIossOffset are local.
      // ioss[localIossOffset+i] = file[local_map[i]];
      size_t localIossOffset;
      std::vector<int> localMap;

      // Maps from file-block data to export list.
      // export[i] = file[export_map[i]
      std::vector<int> exportMap;
      std::vector<int> exportCount;
      std::vector<int> exportIndex;


      // Maps from import data to ioss-block data.
      // ioss[import_map[i] = local_map[i];
      std::vector<int> importMap;
      std::vector<int> importCount;
      std::vector<int> importIndex;
  };

  class SetDecompositionData 
  {
  public:
    SetDecompositionData()
      : fileCount(0), id_(0), root_(0)
      {}

      int64_t id() const {return id_;}
      size_t file_count() const {return fileCount;}
      size_t ioss_count() const {return entitylist_map.size();}

      // contains global entity-list positions for all entities in this set on this processor. 
      std::vector<int> entitylist_map;
      std::vector<bool> hasEntities; // T/F if this set exists on processor p

      size_t fileCount; // Number of nodes in nodelist for file decomposition
      int64_t id_;
      int root_;  // Lowest number processor that has nodes for this nodest
  };

  class DecompositionDataBase
  {
  public:
    DecompositionDataBase(MPI_Comm comm) : comm_(comm),
      myProcessor(0), processorCount(0), spatialDimension(0), globalNodeCount(0),
      globalElementCount(0), elementCount(0), elementOffset(0), importPreLocalElemIndex(0),
      nodeCount(0), nodeOffset(0), importPreLocalNodeIndex(0)
      {}

      virtual ~DecompositionDataBase() {}
      virtual void decompose_model(int cgnsFilePtr) = 0;

      MPI_Comm comm_;
      int myProcessor;
      int processorCount;

      size_t spatialDimension;
      size_t globalNodeCount;
      size_t globalElementCount;

      // Values for the file decomposition 
      size_t elementCount;
      size_t elementOffset;
      size_t importPreLocalElemIndex;

      size_t nodeCount;
      size_t nodeOffset;
      size_t importPreLocalNodeIndex;

      std::vector<double> centroids_;

      std::vector<BlockDecompositionData> el_blocks;
      std::vector<SetDecompositionData> node_sets;
      std::vector<SetDecompositionData> side_sets;
  };

  template <typename INT>
    class DecompositionData;

  template <typename INT>
    class DecompositionData : public DecompositionDataBase
  {
  public:
    DecompositionData(const Ioss::PropertyManager &props,
		      MPI_Comm communicator);
    ~DecompositionData() {}

    void decompose_model(int cgnsFilePtr);

  private:
#if !defined(NO_ZOLTAN_SUPPORT)
    void zoltan_decompose(const std::string &method);
#endif
    void simple_decompose(const std::string &method,
			  const std::vector<INT> &element_dist);
      
    bool i_own_node(size_t node) const; // T/F if node with global index node owned by this processors ioss-decomp.
    bool i_own_elem(size_t elem) const; // T/F if node with global index elem owned by this processors ioss-decomp.
    
    // global_index is 1-based index into global list of nodes [1..global_node_count]
    // return value is 1-based index into local list of nodes on this
    // processor (ioss-decomposition)
    size_t node_global_to_local(size_t global_index) const;
    size_t elem_global_to_local(size_t global_index) const;

    void build_global_to_local_elem_map();
    void get_element_block_communication();

    void generate_adjacency_list(int fileId, std::vector<INT> &pointer,
				 std::vector<INT> &adjacency);

    void calculate_element_centroids(int cgnsFilePtr,
				     const std::vector<INT> &pointer,
				     const std::vector<INT> &adjacency,
				     const std::vector<INT> &node_dist);
#if !defined(NO_ZOLTAN_SUPPORT)
    void get_local_element_list(const ZOLTAN_ID_PTR &export_global_ids, size_t export_count);
#endif

    void get_shared_node_list();

    void get_local_node_list(const std::vector<INT> &pointer,
			     const std::vector<INT> &adjacency,
			     const std::vector<INT> &node_dist);

    std::vector<INT> localElementMap;

    std::vector<INT> importElementMap;
    std::vector<INT> importElementCount;
    std::vector<INT> importElementIndex;

    std::vector<INT> exportElementMap;
    std::vector<INT> exportElementCount;
    std::vector<INT> exportElementIndex;

    std::vector<INT> nodeIndex;

    // Note that nodeGTL is a sorted vector.
    std::vector<INT> nodeGTL;  // Convert from global index to local index (1-based)
    std::map<INT,INT> elemGTL;  // Convert from global index to local index (1-based)

    std::vector<INT> exportNodeMap;
    std::vector<INT> exportNodeCount;
    std::vector<INT> exportNodeIndex;

    std::vector<INT> importNodeMap; // Where to put each imported nodes data in the list of all data...
    std::vector<INT> importNodeCount;
    std::vector<INT> importNodeIndex;

    std::vector<INT> localNodeMap;

    std::vector<INT> nodeCommMap; // node/processor pair of the
    // nodes I communicate with.  Stored node#,proc,node#,proc, ...

    // The global element at index 'I' (0-based) is on block B in the file decompositoin.
    // if fileBlockIndex[B] <= I && fileBlockIndex[B+1] < I
    std::vector<size_t> fileBlockIndex;

    Ioss::PropertyManager m_properties;
  };
}
#endif

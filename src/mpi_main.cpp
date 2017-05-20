/*
 * mpi_main.cpp
 * 
 *   Created on :2017/05/14
 *      Auther: goto
 */


#include<iostream>
#include"mpi.h"
#include"mpi_common.h"
#include"logger.h"
#include"common.h"
#include"align_main_mpi.h"

using namespace std;

void PrintUsageMPI(){
	Logger *logger = Logger::GetInstance();
	logger->Log(
				string("GHOSTZ-GPU-MPI version" + common::kVersion)
				);
	//PrintUsage();
	
}


#ifdef F_MPI
int main(int argc, char* argv[]){
#else
int mpi_main(int argc,char* argv[]){
#endif
	int ret=0;
    if(argc < 2 || strcmp(argv[1], "-h") == 0
		|| strcmp(argv[1], "--help") == 0) {
        PrintUsageMPI();
        exit(1);
    }
	if(strcmp(argv[1],"test")==0){
		
		MPI::Init(argc,argv);
		int rank = MPI::COMM_WORLD.Get_rank();
		cout<<"test:rank"<<rank<<endl;
		MPICommon common;
		common.debug(argc-1,argv+1);
		
		
		MPI::Finalize();
	}
	
	if(strcmp(argv[1],"db")==0){
		cerr<<"db command is available in only non-MPI ghostz."<<endl;
		exit(1);
	}
	

	if(strcmp(argv[1],"aln")==0){
		
		int ret=MPI::Init_thread(argc,argv,MPI_THREAD_MULTIPLE);
		int rank = MPI::COMM_WORLD.Get_rank();
		cout<<"rank"<<rank<<":"<<ret<<":"<<MPI_THREAD_SERIALIZED<<endl;
		
		MPICommon::MPIParameter mpi_parameter;
		mpi_parameter.rank=rank;
		AlignMainMPI main;
		if(rank==0){
			ret=main.Run(argc-1,argv+1,mpi_parameter);
		}else{
			ret=0; //test : only rank0 do aln 
		}
		MPI::Finalize();
			
		}
		return 0;
		
}

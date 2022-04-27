// Function: functionName()
// Variable: variable_name

//Sample file for students to get their code running
// Equal to element go to right

// POINT NODE DATA:
// 0-4 bytes - node_type (1 for point node)
// 4-8 bytes - split_dim
// 8-12 bytes - parent (-1 for root)
// Each point take - 4d + 4 bytes - first 4*d bytes as point, last 4 bytes as childId

// REGION NODE DATA:
// 0-4 bytes - node_type (0 for region node)
// 4-8 bytes - split_dim
// 8-12 bytes - parent (-1 for root)
// Each point take - (2d + 1)*4 bytes - first 4*d bytes as rmin, first 4*d bytes as rmax, last 4 bytes as childId

// TODO: Remove num_points = 3, split_element = 7
#include<iostream>
#include "file_manager.h"
#include "errors.h"
#include<cstring>
#include<bits/stdc++.h>

using namespace std;

class kdbtree{
	public:
		int root;
		int num_points;
		int num_regions;
		ofstream outputFile;

		kdbtree(int d, string f){
			root = -1;
			// num_points = 3;
			// num_regions = 3;
			num_regions = ((int)(PAGE_CONTENT_SIZE - 2*sizeof(int)) / ((2*d + 1)*4)) - 1;
			num_points = ((int)(PAGE_CONTENT_SIZE - 2*sizeof(int)) / ((d + 1)*4)) - 1;
			outputFile.open(f);
		}

		// Return true if rmin <= point < rmax
		bool isIn(int rmin[], int rmax[], int point[], int d){
			for(int i = 0; i < d; i++){
				if(point[i] < rmin[i]){
					return false;
				}
				if(point[i] >= rmax[i]){
					return false;
				}
			}
			return true;
		}

		bool insertPQuery(int data[], int d, FileHandler fh){
			if(root == -1){
				return false;
			}
			int node = root;
			int node_type;
			PageHandler ph = fh.PageAt(node);
			char *page_data = ph.GetData ();
			memcpy (&node_type, &page_data[0], sizeof(int));
			int cid = -1;
			int pad;
			while(node_type != 1){
				fh.UnpinPage(node);
				for(int i = 12; i < PAGE_CONTENT_SIZE; i = i + ((2*d + 1)*4)){
					memcpy(&pad, &page_data[i], sizeof(int));
					if(pad == -1000000){
						break;
					}
					int rmin[d];
					int rmax[d];
					int count = 0;
					for(int j = i; j < i + 4*d; j = j + 4){
						memcpy(&rmin[count++], &page_data[j], sizeof(int));
					}
					count = 0;
					for(int j = i + 4*d; j < i + 8*d; j = j + 4){
						memcpy(&rmax[count++], &page_data[j], sizeof(int));
					}

					if(isIn(rmin, rmax, data, d)){
						memcpy (&node, &page_data[i + 8*d], sizeof(int));
						break;
					}
				}
				ph = fh.PageAt(node);
				page_data = ph.GetData ();
				memcpy (&node_type, &page_data[0], sizeof(int));
			}

			for(int i = 12; i < PAGE_CONTENT_SIZE; i = i + ((d + 1)*4)){
				bool found = true;
				memcpy(&pad, &page_data[i], sizeof(int));
				if(pad == -1000000){
					break;
				}
				for(int j = 0; j < d; j++){
					int ndata;
					memcpy(&ndata, &page_data[i + 4*j], sizeof(int));
					if(ndata != data[j]){
						found = false;
						break;
					}
				}
				if(found){
					return true;
				}
				
			}
			fh.UnpinPage(node);
			return false;
		}

		void insertionPrint(int data[], int d, FileHandler fh){
			if(root == -1){
				return;
			}
			outputFile << "INSERTION DONE:" << endl;
			int node = root;
			int node_type;
			PageHandler ph = fh.PageAt(node);
			char *page_data = ph.GetData ();
			memcpy (&node_type, &page_data[0], sizeof(int));
			int cid = -1;
			int pad;
			int regions_touched = 0;
			while(node_type != 1){
				regions_touched++;
				fh.UnpinPage(node);
				for(int i = 12; i < PAGE_CONTENT_SIZE; i = i + ((2*d + 1)*4)){
					memcpy(&pad, &page_data[i], sizeof(int));
					if(pad == -1000000){
						break;
					}
					int rmin[d];
					int rmax[d];
					int count = 0;
					for(int j = i; j < i + 4*d; j = j + 4){
						memcpy(&rmin[count++], &page_data[j], sizeof(int));
					}
					count = 0;
					for(int j = i + 4*d; j < i + 8*d; j = j + 4){
						memcpy(&rmax[count++], &page_data[j], sizeof(int));
					}

					if(isIn(rmin, rmax, data, d)){
						memcpy (&node, &page_data[i + 8*d], sizeof(int));
						break;
					}
				}
				ph = fh.PageAt(node);
				page_data = ph.GetData ();
				memcpy (&node_type, &page_data[0], sizeof(int));
			}

			for(int i = 12; i < PAGE_CONTENT_SIZE; i = i + ((d + 1)*4)){
				memcpy(&pad, &page_data[i], sizeof(int));
				if(pad == -1000000){
					break;
				}
				for(int j = 0; j < d; j++){
					int ndata;
					memcpy(&ndata, &page_data[i + 4*j], sizeof(int));
					outputFile << ndata;
					if(j != d - 1){
						outputFile << " ";
					}
				}
				outputFile << endl;
				
			}
			outputFile << endl << endl;
			fh.UnpinPage(node);
		}

		// 0 represents region node, 1 represents point node
		void insert(int data[], int d, FileHandler &fh){
			if(insertPQuery(data, d, fh)){
				outputFile << data[0] << data[1] << endl;
				outputFile << "DUPLICATE POINT" << endl << endl << endl;
				return;
			}
			int node_type;
			int split_dim;
			int cid;
			PageHandler ph;
			char *page_data;
			int pad = -1000000;
			int parent;

			// If root is not pointing to any page, create a new page
			if(root == -1){
				ph = createPage(fh);
				page_data = ph.GetData ();
				root = ph.GetPageNum();
				node_type = 1;
				split_dim = 0;
				cid = -1;
				parent = -1;
				memcpy (&page_data[0], &node_type, sizeof(int));
				memcpy (&page_data[4], &split_dim, sizeof(int));
				memcpy (&page_data[8], &parent, sizeof(int));
				outputFile << "INSERTION DONE:" << endl;
				for(int i = 0; i < d; i++){
					outputFile << data[i];
					if(i != d - 1){
						outputFile << " ";
					}
					memcpy(&page_data[12 + 4*i], &data[i], sizeof(int));
				}
				outputFile << endl << endl << endl;
				memcpy (&page_data[12 + 4*d], &cid, sizeof(int));
				fh.MarkDirty(root);
				fh.UnpinPage(root);
			}

			else{
				int node = root;
				ph = fh.PageAt(node);
				page_data = ph.GetData ();
				memcpy (&node_type, &page_data[0], sizeof(int));
				cid = -1;
				while(node_type != 1){
					fh.UnpinPage(node);
					for(int i = 12; i < PAGE_CONTENT_SIZE; i = i + ((2*d + 1)*4)){
						memcpy(&pad, &page_data[i], sizeof(int));
						if(pad == -1000000){
							break;
						}
						int rmin[d];
						int rmax[d];
						int count = 0;
						for(int j = i; j < i + 4*d; j = j + 4){
							memcpy(&rmin[count++], &page_data[j], sizeof(int));
						}
						count = 0;
						for(int j = i + 4*d; j < i + 8*d; j = j + 4){
							memcpy(&rmax[count++], &page_data[j], sizeof(int));
						}

						if(isIn(rmin, rmax, data, d)){
							memcpy (&node, &page_data[i + 8*d], sizeof(int));
							break;
						}
					}
					ph = fh.PageAt(node);
					page_data = ph.GetData ();
					memcpy (&node_type, &page_data[0], sizeof(int));
				}
				int count = 0;
				int start;
				for(int i = 12; i < PAGE_CONTENT_SIZE; i = i + ((d + 1)*4)){
					memcpy(&pad, &page_data[i], sizeof(int));
					if(pad == -1000000){
						start = i;
						break;
					}
					for(int i = 0; i < d; i++){
						int point;
						memcpy(&point, &page_data[i], sizeof(int));
					}
					count++;
				}
				if(count < num_points){
					for(int i = 0; i < d; i++){
						memcpy(&page_data[start + 4*i], &data[i], sizeof(int));
					}
					memcpy(&page_data[start + 4*d], &cid, sizeof(int));
					fh.MarkDirty(node);
					fh.UnpinPage(node);
				}
				else{
					for(int i = 0; i < d; i++){
						memcpy(&page_data[start + 4*i], &data[i], sizeof(int));
					}
					memcpy(&page_data[start + 4*d], &cid, sizeof(int));
					fh.MarkDirty(node);
					fh.UnpinPage(node);
					reorganization(fh, node, d, num_points, num_regions);
				}
				insertionPrint(data, d, fh);
			}
		}

		void reorganization(FileHandler &fh, int node, int d, int num_points, int num_regions){
			PageHandler ph = fh.PageAt(node);
			int node_type;
			int split_dim;
			int parent;
			char *page_data = ph.GetData ();
			int cur_node = ph.GetPageNum();
			int min = INT_MIN;
			int max = INT_MAX;
			memcpy(&node_type, &page_data[0], sizeof(int));
			memcpy(&split_dim, &page_data[4], sizeof(int));
			memcpy(&parent, &page_data[8], sizeof(int));
			int num_count = 0;
			int split_element;
			if(node_type == 0){
				int elements[num_regions];
				int count = 0;
				for(int i = 12; i < PAGE_CONTENT_SIZE; i = i + 8*d + 4){
					int pad;
					memcpy(&pad, &page_data[i], sizeof(int));
					if(pad == -1000000){
						break;
					}
					memcpy(&elements[count++], &page_data[i + 4*split_dim], sizeof(int));
				}	
				split_element = findMedian(elements, num_regions);
				// split_element = 7;      // Remove this
			}
			else{
				int elements[num_points];
				int count = 0;
				for(int i = 12; i < PAGE_CONTENT_SIZE; i = i + 4*d + 4){
					int pad;
					memcpy(&pad, &page_data[i], sizeof(int));
					if(pad == -1000000){
						break;
					}
					memcpy(&elements[count++], &page_data[i + 4*split_dim], sizeof(int));
				}
				split_element = findMedian(elements, num_regions);
			}
			fh.UnpinPage(node);
			pair<int, int> splitted_nodes = nodeSplit(fh, node, split_element, split_dim, d, true);
			ph = fh.PageAt(node);
			page_data = ph.GetData ();
			PageHandler lpage = fh.PageAt(splitted_nodes.first);
			PageHandler rpage = fh.PageAt(splitted_nodes.second);
			int lpage_num = lpage.GetPageNum();
			int rpage_num = rpage.GetPageNum();
			char *lpage_data = lpage.GetData();
			char *rpage_data = rpage.GetData();
			fh.DisposePage(ph.GetPageNum());
			PageHandler parent_page;
			char *parent_data;

			if(parent == -1){
				parent_page = createPage(fh);
				parent = parent_page.GetPageNum();
				parent_data = parent_page.GetData ();
				int parent_type = 0, parent_dim = 0, parent_parent = -1;
				memcpy(&parent_data[0], &parent_type, sizeof(int));
				memcpy(&parent_data[4], &parent_dim, sizeof(int));
				memcpy(&parent_data[8], &parent_parent, sizeof(int));

				// Adding Left Node
				for(int i = 12; i < 12 + 4*d; i = i + 4){
					memcpy(&parent_data[i], &min, sizeof(int));
				}
				for(int i = 12 + 4*d; i < 12 + 8*d; i = i + 4){
					memcpy(&parent_data[i], &max, sizeof(int));
				}
				memcpy(&parent_data[12 + 8*d], &lpage_num, sizeof(int));
				memcpy(&parent_data[12 + 4*d + split_dim*4], &split_element, sizeof(int));

				// Adding Right Node
				for(int i = 12 + 8*d + 4; i < 12 + 8*d + 4 + 4*d; i = i + 4){
					memcpy(&parent_data[i], &min, sizeof(int));
				}
				for(int i = 12 + 8*d + 4 + 4*d; i < 12 + 8*d + 4 + 8*d; i = i + 4){
					memcpy(&parent_data[i], &max, sizeof(int));
				}
				memcpy(&parent_data[12 + 8*d + 4 + 8*d], &rpage_num, sizeof(int));
				memcpy(&parent_data[12 + 8*d + 4 + split_dim*4], &split_element, sizeof(int));
				num_count = 2;
				root = parent_page.GetPageNum();
			}
			else{
				parent_page = fh.PageAt(parent);
				parent_data = parent_page.GetData ();
				int child_pointer;
				int prev_max;
				int pad;
				for(int i = 12; i < PAGE_CONTENT_SIZE; i = i + ((2*d + 1)*4)){
					memcpy(&pad, &parent_data[i], sizeof(int));
					if(pad == -1000000){

						// Adding Right Node
						for(int j = i; j < i + 8*d; j = j + 4){
							memcpy(&parent_data[j], &parent_data[child_pointer + j - i], sizeof(int));
						}

						memcpy(&parent_data[i + 8*d], &rpage_num, sizeof(int));
						memcpy(&parent_data[i + split_dim*4], &split_element, sizeof(int));

						// Adding Left Node (Replacing Original Node by Left Node)
						memcpy(&parent_data[child_pointer + 8*d], &lpage_num, sizeof(int));
						memcpy(&parent_data[child_pointer + 4*d + split_dim*4], &split_element, sizeof(int));
						num_count++;
						break;
					}
					num_count++;
					int child;
					memcpy(&child, &parent_data[i + 8*d], sizeof(int));
					if(child == cur_node){
						child_pointer = i;
					}
				}
			}

			memcpy(&lpage_data[8], &parent, sizeof(int));
			memcpy(&rpage_data[8], &parent, sizeof(int));
			fh.MarkDirty(lpage_num);
			fh.UnpinPage(lpage_num);
			fh.MarkDirty(rpage_num);
			fh.UnpinPage(rpage_num);
			fh.MarkDirty(parent_page.GetPageNum());
			fh.UnpinPage(parent_page.GetPageNum());
			if(num_count > num_regions){
				reorganization(fh, parent_page.GetPageNum(), d, num_points, num_regions);
			}
			
		}

		void print(PageHandler &ph){
			cout << "Page No: " << ph.GetPageNum() << endl;
			char *page_data = ph.GetData ();
			for(int i = 0; i < PAGE_CONTENT_SIZE; i = i + 4){
				int num;
				memcpy(&num, &page_data[i], sizeof(int));
				if(num == -1000000){
					cout << endl;
					break;
				}
				cout << num << " ";
			}
			cout << endl;
		}

		void printTree(FileHandler &fh, int d){
			int node;
			queue<int> q;
			q.push(root);
			while(q.size() != 0){
				node = q.front();
				q.pop();
				PageHandler ph = fh.PageAt(node);
				char *page_data = ph.GetData ();
				fh.UnpinPage(node);
				print(ph);
				int node_type;
				memcpy(&node_type, &page_data[0], sizeof(int));
				if(node_type == 1){
					continue;
				}
				for(int i = 12 + 8*d; i < PAGE_CONTENT_SIZE; i = i + ((2*d + 1)*4)){
					int pad;
					memcpy(&pad, &page_data[i], sizeof(int));
					if(pad == -1000000){
						break;
					}
					q.push(pad);
				}
			}
		}

		PageHandler createPage(FileHandler &fh){
			int pad = -1000000;
			PageHandler ph = fh.NewPage();
			char *page_data = ph.GetData();
			for(int i = 0; i < PAGE_CONTENT_SIZE; i = i + 4){
				memcpy(&page_data[i], &pad, sizeof(int));
			}
			return ph;
		}

		pair<int, int> nodeSplit(FileHandler &fh, int node, int split_element, int fix_split_dim, int d, bool change){
			PageHandler ph = fh.PageAt(node);
			int node_type;
			int split_dim;
			int parent;
			char *page_data = ph.GetData ();
			memcpy(&node_type, &page_data[0], sizeof(int));
			memcpy(&split_dim, &page_data[4], sizeof(int));
			memcpy(&parent, &page_data[8], sizeof(int));
			PageHandler lpage = createPage(fh);
			PageHandler rpage = createPage(fh);
			char *lpage_data = lpage.GetData ();
			char *rpage_data = rpage.GetData ();
			int new_split_dim;
			if(change){
				new_split_dim = (split_dim + 1) % d;
			}
			else{
				new_split_dim = split_dim;
			}
			int lpage_num = lpage.GetPageNum();
			int rpage_num = rpage.GetPageNum();
			memcpy(&lpage_data[0], &node_type, sizeof(int));
			memcpy(&lpage_data[4], &new_split_dim, sizeof(int));
			memcpy(&lpage_data[8], &parent, sizeof(int));
			memcpy(&rpage_data[0], &node_type, sizeof(int));
			memcpy(&rpage_data[4], &new_split_dim, sizeof(int));
			memcpy(&rpage_data[8], &parent, sizeof(int));
			int lpage_offset = 12, rpage_offset = 12;
			pair<int, int> splitted_nodes = {lpage_num, rpage_num};
			if(node_type == 0){
				for(int i = 12; i < PAGE_CONTENT_SIZE; i = i + 8*d + 4){
					int pad;
					memcpy(&pad, &page_data[i], sizeof(int));
					if(pad == -1000000){
						break;
					}
					int min, max;
					memcpy(&min, &page_data[i + 4*fix_split_dim], sizeof(int));
					memcpy(&max, &page_data[i + 4*d + 4*fix_split_dim], sizeof(int));
					if(min >= split_element){
						int child_node;
						memcpy(&child_node, &page_data[i + 8*d], sizeof(int));
						PageHandler child_page = fh.PageAt(child_node);
						char *d1 = child_page.GetData();
						memcpy(&d1[8], &rpage_num, sizeof(int));
						memcpy(&rpage_data[rpage_offset], &page_data[i], (2*d + 1)*sizeof(int));
						rpage_offset += 8*d + 4;
						fh.MarkDirty(child_node);
						fh.UnpinPage(child_node);
					}
					else if(max <= split_element){
						int child_node;
						memcpy(&child_node, &page_data[i + 8*d], sizeof(int));
						PageHandler child_page = fh.PageAt(child_node);
						char *d1 = child_page.GetData();
						memcpy(&d1[8], &lpage_num, sizeof(int));
						memcpy(&lpage_data[lpage_offset], &page_data[i], (2*d + 1)*sizeof(int));
						lpage_offset += 8*d + 4;
						fh.MarkDirty(child_node);
						fh.UnpinPage(child_node);
					}
					else{
						int next_split;
						memcpy(&next_split, &page_data[i + 8*d], sizeof(int));
						fh.MarkDirty(node);
						fh.MarkDirty(lpage_num);
						fh.MarkDirty(rpage_num);
						fh.UnpinPage(lpage_num);
						fh.UnpinPage(rpage_num);
						fh.UnpinPage(node);
						PageHandler next_page = fh.PageAt(next_split);
						pair<int, int> child_nodes = nodeSplit(fh, next_page.GetPageNum(), split_element, fix_split_dim, d, false);
						ph = fh.PageAt(node);
						lpage = fh.PageAt(lpage_num);
						rpage = fh.PageAt(rpage_num);
						page_data = ph.GetData();
						lpage_data = lpage.GetData ();
						rpage_data = rpage.GetData ();
						int lchild_num = child_nodes.first;
						int rchild_num = child_nodes.second;
						PageHandler p1 = fh.PageAt(lchild_num);
						PageHandler p2 = fh.PageAt(rchild_num);
						char *d1 = p1.GetData();
						char *d2 = p2.GetData();

						// Add lnode, lchild
						memcpy(&lpage_data[lpage_offset], &page_data[i], (2*d + 1)*sizeof(int));
						memcpy(&lpage_data[lpage_offset + 8*d], &lchild_num, sizeof(int));
						memcpy(&lpage_data[lpage_offset + 4*d + split_dim*4], &split_element, sizeof(int));
						memcpy(&d1[8], &lpage_num, sizeof(int));

						// Add rnode, rchild
						memcpy(&rpage_data[rpage_offset], &page_data[i], (2*d + 1)*sizeof(int));
						memcpy(&rpage_data[rpage_offset + 8*d], &rchild_num, sizeof(int));
						memcpy(&rpage_data[rpage_offset + split_dim*4], &split_element, sizeof(int));
						memcpy(&d2[8], &rpage_num, sizeof(int));

						lpage_offset += 8*d + 4;
						rpage_offset += 8*d + 4;

						fh.MarkDirty(lchild_num);
						fh.UnpinPage(lchild_num);
						fh.MarkDirty(rchild_num);
						fh.UnpinPage(rchild_num);

					}
				}
			}
			else{
				for(int i = 12; i < PAGE_CONTENT_SIZE; i = i + 4*d + 4){
					int pad;
					memcpy(&pad, &page_data[i], sizeof(int));
					if(pad == -1000000){
						break;
					}
					int num;
					memcpy(&num, &page_data[i + 4*fix_split_dim], sizeof(int));
					if(num < split_element){
						memcpy(&lpage_data[lpage_offset], &page_data[i], (d + 1)*sizeof(int));
						lpage_offset += 4*d + 4;
					}
					else{
						memcpy(&rpage_data[rpage_offset], &page_data[i], (d + 1)*sizeof(int));
						rpage_offset += 4*d + 4;
					}
				}
			}
			fh.MarkDirty(lpage.GetPageNum());
			fh.MarkDirty(rpage.GetPageNum());
			fh.UnpinPage(lpage.GetPageNum());
			fh.UnpinPage(rpage.GetPageNum());
			return splitted_nodes;
		}

		int findMedian(int elements[], int n){
			sort(elements, elements + n);
			set<int> s;
			 for (int i = 0; i < n; i++) {
		        s.insert(elements[i]);
		    }
		    vector<int> v;
		    set<int>::iterator it;
		    for (it = s.begin(); it != s.end(); it++){
		    	v.push_back(*it);
		    }
		    int new_n = v.size();
			return v[new_n/2];
		}

		void pQuery(int data[], int d, FileHandler fh){
			if(root == -1){
				outputFile << "NUM REGION NODES TOUCHED: " << 0 << endl;
				outputFile << "FALSE" << endl;
				outputFile << endl << endl;
				return;
			}
			int node = root;
			int node_type;
			PageHandler ph = fh.PageAt(node);
			char *page_data = ph.GetData ();
			memcpy (&node_type, &page_data[0], sizeof(int));
			int cid = -1;
			int pad;
			int regions_touched = 0;
			while(node_type != 1){
				regions_touched++;
				fh.UnpinPage(node);
				for(int i = 12; i < PAGE_CONTENT_SIZE; i = i + ((2*d + 1)*4)){
					memcpy(&pad, &page_data[i], sizeof(int));
					if(pad == -1000000){
						break;
					}
					int rmin[d];
					int rmax[d];
					int count = 0;
					for(int j = i; j < i + 4*d; j = j + 4){
						memcpy(&rmin[count++], &page_data[j], sizeof(int));
					}
					count = 0;
					for(int j = i + 4*d; j < i + 8*d; j = j + 4){
						memcpy(&rmax[count++], &page_data[j], sizeof(int));
					}

					if(isIn(rmin, rmax, data, d)){
						memcpy (&node, &page_data[i + 8*d], sizeof(int));
						break;
					}
				}
				ph = fh.PageAt(node);
				page_data = ph.GetData ();
				memcpy (&node_type, &page_data[0], sizeof(int));
			}

			for(int i = 12; i < PAGE_CONTENT_SIZE; i = i + ((d + 1)*4)){
				bool found = true;
				memcpy(&pad, &page_data[i], sizeof(int));
				if(pad == -1000000){
					break;
				}
				for(int j = 0; j < d; j++){
					int ndata;
					memcpy(&ndata, &page_data[i + 4*j], sizeof(int));
					if(ndata != data[j]){
						found = false;
						break;
					}
				}
				if(found){
					outputFile << "NUM REGION NODES TOUCHED: " << regions_touched << endl;
					outputFile << "TRUE" << endl;
					outputFile << endl << endl;
					return;
				}
				
			}
			outputFile << "NUM REGION NODES TOUCHED: " << 0 << endl;
			outputFile << "FALSE" << endl;
			outputFile << endl << endl;
			fh.UnpinPage(node);
			return;
		}

		bool isInR(int rmin[], int rmax[], int qrmin[], int qrmax[], int d){
			for(int i = 0; i < d; i++){
				if(qrmax[i] < rmin[i] || qrmin[i] > rmax[i]){
					return false;
				}
			}
			return true;
		}

		bool isLying(int rmin[], int rmax[], int point[], int d){
			for(int i = 0; i < d; i++){
				if(point[i] < rmin[i]){
					return false;
				}
				if(point[i] > rmax[i]){
					return false;
				}
			}
			return true;
		}

		void rQuery(int qrmin[], int qrmax[], int d, FileHandler fh){
			if(root == -1){
				outputFile << "NO POINT FOUND" << endl;
				return;
			}
			bool found = false;
			queue<pair<int, int>> q;
			q.push({root, 0});
			int pad;
			while(!q.empty()){
				pair<int, int> p = q.front();
				int node = p.first;
				q.pop();
				int node_type;
				PageHandler ph = fh.PageAt(node);
				fh.UnpinPage(node);
				char *data = ph.GetData();
				memcpy(&node_type, &data[0], sizeof(int));
				if(node_type == 1){
					for(int i = 12; i < PAGE_CONTENT_SIZE; i = i + 4*(d + 1)){
						memcpy(&pad, &data[i], sizeof(int));
						if(pad == -1000000){
							break;
						}
						int point[d];
						for(int j = 0; j < d; j++){
							memcpy(&point[j], &data[i + 4*j], sizeof(int));
						}
						if(isLying(qrmin, qrmax, point, d)){
							found = true;
							outputFile << "POINT: ";
							for(int j = 0; j < d; j++){
								outputFile << point[j] << " ";
							}
							outputFile << "NUM REGION NODES TOUCHED: " << p.second;
							outputFile << endl;
						}
					}
				}
				else{
					for(int i = 12; i < PAGE_CONTENT_SIZE; i = i + 4*(2*d + 1)){
						memcpy(&pad, &data[i], sizeof(int));
						if(pad == -1000000){
							break;
						}
						int rmin[d];
						int rmax[d];
						int count = 0;
						for(int j = i; j < i + 4*d; j = j + 4){
							memcpy(&rmin[count++], &data[j], sizeof(int));
						}
						count = 0;
						for(int j = i + 4*d; j < i + 8*d; j = j + 4){
							memcpy(&rmax[count++], &data[j], sizeof(int));
						}

						if(isInR(rmin, rmax, qrmin, qrmax, d)){
							memcpy (&node, &data[i + 8*d], sizeof(int));
							// cout << "Node: " << node << endl;
							q.push({node, p.second + 1});
						}
					}
				}
			}
			if(!found){
				outputFile << "NO POINT FOUND" << endl;
			}
			outputFile << endl << endl;
		}
};

int main(int argc, char* argv[]) {

	ifstream inputFile(argv[1]);
	int d = stoi(argv[2]);
	kdbtree tree(d, argv[3]);

	FileManager fm;

	FileHandler fh = fm.CreateFile("temp.txt");

	string line;
	while(getline(inputFile, line)){
		istringstream ss(line);
		string query;
		getline(ss, query, ' ');
		if(query == "INSERT"){
			int data[d];
			for(int i = 0; i < d; i++){
				string s;
				getline(ss, s, ' ');
				data[i] = stoi(s);
			}
			tree.insert(data, d, fh);
		}
		else if(query == "PQUERY"){
			int data[d];
			for(int i = 0; i < d; i++){
				string s;
				getline(ss, s, ' ');
				data[i] = stoi(s);
			}
			tree.pQuery(data, d, fh);
		}
		else{
			int qrmin[d];
			int qrmax[d];
			for(int i = 0; i < d; i++){
				string s;
				getline(ss, s, ' ');
				qrmin[i] = stoi(s);
				getline(ss, s, ' ');
				qrmax[i] = stoi(s);
			}
			tree.rQuery(qrmin, qrmax, d, fh);
		}
		fm.PrintBuffer();
	}
	// tree.printTree(fh, d);
	fm.CloseFile (fh);
	fm.DestroyFile ("temp.txt");
}

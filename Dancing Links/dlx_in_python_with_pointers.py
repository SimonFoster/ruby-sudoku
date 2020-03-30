## Knuth's "Algorithm X" implemented with Dancing Links, _implemented
## with actual pointers_, and all in Python.
##
## Coded by Nicolau Werneck <nwerneck@gmail.com> in 2011-05-09

# SF See: https://xor0110.wordpress.com/2011/05/09/dlx-in-python-with-actual-pointers/

class Node():
    def __init__(self):
        self.u=self
        self.d=self
        self.l=self
        self.r=self
        self.c=self

    def l_sweep(self):
        x=self.l
        while x != self:
            yield x
            x=x.l
        else:
            return

    def r_sweep(self):
        x=self.r
        while x != self:
            yield x
            x=x.r
        else:
            return

    def u_sweep(self):
        x=self.u
        while x != self:
            yield x
            x=x.u
        else:
            return

    def d_sweep(self):
        x=self.d
        while x != self:
            yield x
            x=x.d
        else:
            return

class Matrix():
    def __init__(self, column_labels, lines):
        ## The header node
        self.h = Node()
        h = self.h
        self.hdic = {}

        ## Create the colums headers
        for label in column_labels:
            ## Append new nodes to column header line, reading labels
            ## from input list.
            h.l.r = Node()
            h.l.r.l = h.l
            h.l.r.r = h
            h.l = h.l.r
            h.l.n = label
            self.hdic[label] = h.l

        ## Add lines to the matrix
        for ll in lines:
            last=[]
            for l in ll:
                q = Node()
                ## Get column header
                c = self.hdic[l]

                ## Add new node to column bottom.
                q.u = c.u
                q.d = c
                q.d.u = q
                q.u.d = q
                q.c = c

                ## Tie new node to possibly existing previous row
                ## node.
                if last:
                    q.l = last
                    q.r = last.r
                    q.l.r = q
                    q.r.l = q
                ## Current node becomes "last" node from this row.
                last=q

    ## The search algorithm. First we defoine the cover and uncover
    ## operations.
    def cover(self,c):
        c.r.l = c.l
        c.l.r = c.r
        for i in c.d_sweep():
            for j in i.r_sweep():
                j.d.u = j.u
                j.u.d = j.d                

    def uncover(self,c):
        for i in c.u_sweep():
            for j in i.l_sweep():
                j.d.u = j
                j.u.d = j
        c.r.l = c
        c.l.r = c

    ## Now the actual recursive "search" procedure. Must be called
    ## like this: m.search(0,[]). I tried to keed the code looking as
    ## much as possible like the original definition from Knuth's
    ## article.
    def search(self, k, o_all):
        if self.h.l == self.h:
            for o in o_all:
                print ''.join(self.print_o(o)),
            print
        ## Select leftmost column
        c = self.h.r
        self.cover(c)
        for r in c.d_sweep():
            o_k = r
            for j in r.r_sweep():
                self.cover(j.c)
            self.search(k+1, o_all+[o_k])
            ## Dunno why Knuth put this line in his code, not
            ## necessary. Maybe a premature optimization in mind?
            #r,c = o_k,r.c 
            for j in r.l_sweep():
                self.uncover(j.c)
        self.uncover(c)

    ## To print the solution(s)
    def print_o(self, r):
        out = [r.c.n]
        for x in r.r_sweep():
            out.append(x.c.n)
        return out

##
## Run the damn thing
if __name__ == '__main__':
    cols=['a','b','c','d']
    lines=[['a'],['b'],['c'],['d'],
        ['a','b'],['a','c'],['a','d'],['b','c'],
        ['b','d'],['c','d'],['a','b','c'],['a','b','d'],
        ['a','c','d'],['b','c','d'],['a','b','c','d'],]

    m = Matrix (cols, lines)
    #m.print_matrix()
    m.search(0, [])

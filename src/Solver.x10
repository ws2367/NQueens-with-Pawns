import x10.util.Timer;
import x10.util.ArrayList;
import x10.util.concurrent.AtomicInteger;

/**
 * This is the class that provides the solve() method.
 *
 * The assignment is to replace the contents of the solve() method
 * below with code that actually works :-)
 */
public class Solver
{
    /**
     * Solve a single 'N'-Queens with pawns problem.
     *     'SIZE' is 'N'.
     *     'pawns' is an array of Squares with the locations of pawns.  The array may be of length zero.
     *
     * This function should return the number of solutions for the given configuration.
     */
    val sol = new AtomicInteger(0);
    var pawnsmap:Array[Boolean]{self.rank==2, self.rect==true, self.zeroBased==false, self.rail==false};
    var SIZE:Int;
    var CUTOFF_LEVEL:Int;
   
    //SEGMENTS ARE THE RANK-1 REGIONS DIVIDED BY PAWNS ON THOSE ROWS WITH PAWNS
    var allSegments:Array[Region]{self.rank==1, self.rail==true, 
                                  self.zeroBased==true, self.rect==true};
    

    //EACH NODE IS A INTERMEDIATE STATE
    //
    //rejmap is the rejection map that tells whether a position on the chess board
    //is allowed to put a queen or not.
    //
    //candidate is number of possible candidates for now
    //
    public class Node{
        var candidate   :Int;
        var rejmap      :Array[Boolean]{self.rank==2, self.rect==true, 
                                        self.zeroBased==false, self.rail==false};
            // 1=>reject; 0=>not reject
            
        def this(cand:Int, rejmap:Array[Boolean]{self.rank==2, self.rect==true, 
                                                 self.zeroBased==false, self.rail==false}){
            this.candidate = cand;
            this.rejmap    = rejmap;
        }
    }

    //return true if there are pawns in the given row. return false otherwise.
    private def pawnsInRow(row:Int, tPawnsmap:Array[Boolean]{self.rank==2}):Boolean{
      for(var i:Int=1; i<=SIZE; i++)
        if( tPawnsmap(row, i) ) return true;
      return false;
    }
 
    //Define segments in the rows with pawns
    //segments do not include pawns
    private def segmentsInRow(row:Int, segments:ArrayList[Region], tPawnsmap:Array[Boolean]{self.rank==2}){
      var min:Int=1;
      var max:Int=1;
      var flag:Boolean=false;
      for(var i:Int=1; i<=SIZE; i++){
        if( tPawnsmap(row, i)&&flag){
          max = i-1; 
          flag = false;
          val r:Region{self.rank==2, self.rect==true, 
                       self.zeroBased==false, self.rail==false} = (row..row)*(min..max);
          segments.add(r);
        }
        else if( (!tPawnsmap(row ,i))&&(!flag) ){
          min=i;
          flag = true;
        }
      }
      //For cases that the last entry in the row is not a pawn
      if(flag){
        val r:Region{self.rank==2, self.rect==true, 
                     self.zeroBased==false, self.rail==false} = (row..row)*(min..SIZE);
        segments.add(r); 
      }
    }

    //The segments are divided by a pawns or changing row.
    private def createSegmentsArr(tPawnsmap:Array[Boolean]{self.rank==2}):Array[Region]{
      val segments = new ArrayList[Region]();
      for(var row:Int=1; row<=SIZE; row++){
        if( pawnsInRow(row, tPawnsmap) )
          segmentsInRow(row, segments, tPawnsmap);
        else{ 
          val r:Region{self.rank==2, self.rect==true, 
                       self.zeroBased==false, self.rail==false} = (row..row)*(1..SIZE);
          segments.add(r);
        }
      }
      return segments.toArray();
    }
    
    //IN TERMS OF POSITION: BACK-TRACE DEPTH-FIRST SEARCH 
    //
    //IN TERMS OF SEGMENT: BY SEARCHING THROUGH ALL THE N COMINBATIONS OF SEGMENTS, 
    //PUT N QUEENS ON EACH SEGMENT(MORE THAN N)
    //
    //every segment can only contain one or zero queen
    private def traceSegment(node:Node, level:Int, ind:Int){
      val xMin = allSegments(ind).min(0);
      val xMax = allSegments(ind).max(0);
      val yMin = allSegments(ind).min(1);
      val yMax = allSegments(ind).max(1);

      for(var x:Int=xMin; x<=xMax; x++)
        for(var y:Int=yMin; y<=yMax; y++){
          val col=y;
          val row=x;
          if(row>SIZE) continue;
          else if( node.rejmap(row,col) ) continue;
          else if( (node.candidate+1).equals(SIZE) ) sol.getAndIncrement();
          else{
            //NEW A NODE
            //val newcandidate = node.candidate+1;
            //val newrejmap = createRejMap(row, col, node);
            val childnode = new Node(node.candidate+1, createRejMap(row, col, node));

            //Generating a level of combination of choosing K from N
            val N = allSegments.size;
            val K = SIZE;
            if(level<K)
              for(var j:Int=ind+1; j<=N-K+level; j++){
                val t=j;
                val width = N-K+level-t;
                if( width*(SIZE-level)>=(CUTOFF_LEVEL) )
                  async traceSegment(childnode, level+1, t);
                else
                  traceSegment(childnode, level+1, t);       
              }       
           }
        }
    }
  
    //Note that the new rejection map is only effctive in the undiscovered region which is under the current row
    private def createRejMap(currentrow:Int, pos:Int, node:Node):
    Array[Boolean]{self.rank==2,self.rect==true, self.zeroBased==false, self.rail==false}{
        val oldrejmap = node.rejmap;
        val newrejmap = new Array[Boolean](oldrejmap);

        //set current column 1
        for(var i:Int=currentrow; i<=SIZE; i++){
            if( pawnsmap(i, pos) ) break;
            newrejmap(i, pos)=true;
        }

        //set left side of current row 1
        for(var i:Int=pos; i>=1; i--){
            if( pawnsmap(currentrow, i) ) break;
            newrejmap(currentrow, i)=true;
        }

        //set right side of current row 1
        for(var i:Int=pos+1; i<=SIZE; i++){
            if( pawnsmap(currentrow, i) ) break;
            newrejmap(currentrow, i)=true;
        }

        //set bottom-left diagonal 1
        for(var i:Int=1; ( (currentrow+i)<=SIZE&&(pos-i)>=1 ); i++){
            if( pawnsmap(currentrow+i, pos-i) ) break;
            newrejmap(currentrow+i, pos-i)=true;
        }

        //set bottom-right diagonal 1
        for(var i:Int=1; ( (currentrow+i)<=SIZE&&(pos+i)<=SIZE ); i++){
            if( pawnsmap(currentrow+i, pos+i) ) break;
            newrejmap(currentrow+i, pos+i)=true;
        }
        
        return newrejmap;                
    }
    
    public def solve(size: int, pawns: Array[Square]{rank==1}) : int
    {  
        sol.set(0);
        SIZE = size;
        pawnsmap = new Array[Boolean]((1..SIZE)*(1..SIZE), false);//1-indexed
        
        //Transpose or not    
        val transpawnsmap:Array[Boolean]{self.rank==2, self.rect==true, self.zeroBased==false};
        transpawnsmap = new Array[Boolean]((1..SIZE)*(1..SIZE), false);//1-indexed
        for(var i:Int=0; i<pawns.size; i++){
          val k=i;
            val x = pawns(k).x+1;//from 0-indexed to 1-indexed
            val y = pawns(k).y+1;
            pawnsmap(x, y)      = true;
            transpawnsmap(y, x) = true;
        }
         
        val transSegments:Array[Region]{self.rank==1, self.rail==true, 
                                        self.zeroBased==true, self.rect==true};
        finish {
          async allSegments = createSegmentsArr(pawnsmap);
          transSegments = createSegmentsArr(transpawnsmap);        
        }
        
        if( transSegments.size<allSegments.size ){
          allSegments = transSegments;
          pawnsmap    = transpawnsmap;
	}

        CUTOFF_LEVEL = (0.9*SIZE) as Int;

        val emptyrejmap = new Array[Boolean](pawnsmap);
        val rootnode = new Node(0, emptyrejmap);
      
	//Console.OUT.println("SIZE: "+SIZE);
	
	val N = allSegments.size;
        val K = SIZE;   

        //Generate the level 1 of the combination tree
        finish for(var j:Int=0; j<=N-K; j++){
          val t=j;
          async traceSegment(rootnode, 1, t);
        }
	
        return sol.get();
    }
   
}

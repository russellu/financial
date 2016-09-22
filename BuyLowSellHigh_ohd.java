package jforex;

import java.util.*;
import com.dukascopy.api.*;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.geom.AffineTransform;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Line2D;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.List;
import javax.swing.JFrame;
import javax.swing.JPanel;
import java.io.FilenameFilter;

@RequiresFullAccess //we need full access to access mail library 

public class BuyLowSellHigh_ohd implements IStrategy {
    private IEngine engine;
    private IConsole console;
    private IHistory history;
    private IContext context;
    private IIndicators indicators;
    private IUserInterface userInterface;
    
    public void onStart(IContext context) throws JFException {
        this.engine = context.getEngine();
        this.console = context.getConsole();
        this.history = context.getHistory();
        this.context = context;
        this.indicators = context.getIndicators();
        this.userInterface = context.getUserInterface();
        
        //get the params here: 
        HashMap<String,Double> currMap = getSpreadFile("C:\\Users\\Acer\\Documents\\indices_4\\exp.txt") ; 
        ArrayList<String> availableCurrencies = getAvailableCurrencies("C:\\Users\\Acer\\Documents\\indices_4") ; 
        
        Set<Instrument> instrumentSet = new HashSet<>() ; 
        ArrayList<Instrument> instrumentList = new ArrayList<Instrument>() ; 
        
        for(int i=0;i<availableCurrencies.size();i++){
            console.getOut().println("currn = " + i + " label = " + Instrument.fromString(availableCurrencies.get(i))) ;   
            Instrument instr = Instrument.fromString(availableCurrencies.get(i)) ; 
            instrumentSet.add(instr) ; instrumentList.add(instr) ; 
        }         
        context.setSubscribedInstruments(instrumentSet) ;       
        ArrayList<List<IBar>> allHistBars = new ArrayList<List<IBar>>() ;  
        ArrayList<BasicStrategy1> allStrats = new ArrayList<BasicStrategy1>() ; 
        for(int i=0;i<availableCurrencies.size();i++){//goodCurrs.size()
            String curr = availableCurrencies.get(i).replace("/","") ;  
            console.getOut().println("getting history for instrument " + availableCurrencies.get(i)+" curr = " + curr) ;                 
            long prevBarTime = history.getPreviousBarStart(Period.THIRTY_MINS,history.getTimeOfLastTick(instrumentList.get(i))) ;
            List<IBar> bars = history.getBars(instrumentList.get(i), 
            Period.THIRTY_MINS, OfferSide.BID, history.getTimeForNBarsBack(Period.THIRTY_MINS, prevBarTime, 7500), prevBarTime);                  
            allHistBars.add(bars) ; 
            ArrayList<double[]> mps = getOverheadMvgParams("C:\\Users\\Acer\\Documents\\indices_4\\txt_bestparam-"+curr+"-.txt") ; 
            int stratn = 0 ; 
            allStrats.add(new BasicStrategy1((int)mps.get(stratn)[0],(int)mps.get(stratn)[1],(int)mps.get(stratn)[2],mps.get(stratn)[3],
                                                availableCurrencies.get(i),currMap.get(curr))) ; 
            try{Thread.sleep(500);}catch(Exception e){} 
        }  
        MultiStrat ms = new MultiStrat() ; 
        ms.allStrats = allStrats ; 
        PlotAllTimeSeries pats = new PlotAllTimeSeries(ms) ;
        pats.initFrame() ; 
        console.getOut().println("init finished") ; 
        
        // feed the historical data to the strategy 
        for(int hpoint=1;hpoint<allHistBars.get(0).size();hpoint++){      
            for(int i=0;i<allHistBars.size();i++){
                if(allHistBars.get(i).get(hpoint).getClose() != allHistBars.get(i).get(hpoint-1).getClose()){
                    ms.allStrats.get(i).feedData(allHistBars.get(i).get(hpoint).getClose())  ; 
                    ms.allStrats.get(i).feedDate("x")  ;
                }
            }
        }
        console.getOut().println("strats fed") ; 
        pats.setTrader(0) ; 
        pats.render() ; pats.repaint() ; 
    }

    public void onAccount(IAccount account) throws JFException {
    }

    public void onMessage(IMessage message) throws JFException {
    }

    public void onStop() throws JFException {
    }

    public void onTick(Instrument instrument, ITick tick) throws JFException {
    }
    
    public void onBar(Instrument instrument, Period period, IBar askBar, IBar bidBar) throws JFException {
    }
    
    class MultiStrat{
        public double totalProfit ; 
        public double totalNTrades ; 
        public double totalTradeCost ; 
        public ArrayList<BasicStrategy1> allStrats ; 
        public MultiStrat(){
        }     
        public void sumProfits(){
            totalProfit = 0 ; 
            totalNTrades = 0 ; 
            totalTradeCost = 0 ; 
            for(int i=0;i<allStrats.size();i++){
                totalProfit += allStrats.get(i).totalProfit/allStrats.get(i).scaleFactor ;
                totalNTrades += allStrats.get(i).ntrades ; 
            }
            totalTradeCost = totalNTrades*3.5 ; 
        }    
    }
    
    class BasicStrategy1{
        int mvg1Period ; int mvg2Period ; int mvg3Period ; double tp ; 
        ArrayList<Double> values = new ArrayList<Double>() ; public ArrayList<Double> mvg1 = new ArrayList<Double>() ; 
        public ArrayList<Double> mvg2 = new ArrayList<Double>() ; public ArrayList<Double> mvg3 = new ArrayList<Double>() ;    
        public ArrayList<ArrayList<Double>> allMvgs ; //for the plot drawer   
        public ArrayList<Integer> buyEntryInds = new ArrayList<Integer>() ;public ArrayList<Integer> sellEntryInds = new ArrayList<Integer>() ;
        public ArrayList<Integer> buyExitInds = new ArrayList<Integer>() ;public ArrayList<Integer> sellExitInds = new ArrayList<Integer>() ;
        public ArrayList<Double> cumulativeProfits = new ArrayList<Double>() ; 
        public double upl = 0 ;public double totalProfit = 0 ; double entry = 0 ; public int ntrades = 0 ; 
        boolean inBuy = false ; boolean inSell = false ;
        double commission = 0 ; double slippage = 0 ; 
        public double transactionCostPips =  0 ;  public double estimatedTransactionCost = 0 ; 
        public String pair = "" ; public double scaleFactor = 0 ; public int maxMvgPeriod ;  public int counter = 0 ;   
        public ArrayList<String> dates = new ArrayList<String>() ; 
        public double spread = 0 ; 
        public double overhead = 0 ; 

        public BasicStrategy1(int mvg1Period,int mvg2Period,int mvg3Period,double overhead,String pair,double spread){
            this.pair = pair ; 
            this.mvg1Period = mvg1Period ; 
            this.mvg2Period = mvg2Period ; 
            this.mvg3Period = mvg3Period ; 
            this.overhead = overhead ; 
            this.spread = spread ; 
            if(pair.contains("JPY") || pair.contains("XAG")){
                spread = spread*0.01 ; commission = 0.0035 ; slippage = 0.009 ; //for jpy pairs (1 pip = 0.01)
                scaleFactor = 0.01 ; 
            }
            else{
                spread = spread*0.0001 ; commission = 0.000035 ; slippage = 0.00009 ; //for all other pairs (1 pip = 0.0001)
                scaleFactor = 0.0001 ; 
            }
            transactionCostPips = spread + commission + slippage ; 
            console.getOut().println("curr=" + pair + " spread = " + spread + " scaleFactor = " + scaleFactor) ; 
            int[] pers = {mvg1Period,mvg2Period,mvg3Period} ;
            int maxPeriod = mvg1Period ;
            for(int i=0;i<pers.length;i++)
                if(pers[i] > maxPeriod){
                    maxPeriod = pers[i] ; 
                }
            maxMvgPeriod = maxPeriod ; 
        }
        public void feedDate(String dateString){
            dates.add(dateString) ; 
        }
        public void feedData(double input){
            
            values.add(input) ; 
            
            calculateMvgs(input) ; 
            
            checkIndicators() ; 
            
            if(inBuy || inSell){
                if(inBuy){
                    upl = input-entry ; 
                }
                else if (inSell){
                    upl = entry-input ; 
                }
            }
            counter ++ ; 
            if(counter%25 == 0)
                cumulativeProfits.add(totalProfit) ; 
        }
        public void checkIndicators(){       
            if(values.size()>maxMvgPeriod){           
                double currentValue = values.get(values.size()-1) ; 
                double prevValue = values.get(values.size()-2) ; 
                double mvg1Value = mvg1.get(mvg1.size()-1) ;
                double mvg2Value = mvg2.get(mvg2.size()-1) ;
                double mvg3Value = mvg3.get(mvg3.size()-1) ;     
                if(!inBuy && !inSell){
                    if(currentValue > mvg1Value-overhead){ // price is above m1 (could also optimize this distance)
                        if(currentValue < mvg2Value && prevValue > mvg2Value){ // price cross m2 going down
                            inBuy = true ; 
                            entry = currentValue; 
                            buyEntryInds.add(values.size()-1) ;
                            ntrades ++ ; 
                        }
                    }
                    else if(currentValue < mvg1Value+overhead){ // price is below m1
                        if(currentValue > mvg2Value && prevValue < mvg2Value){ // price crosses m2 going up
                            inSell = true ; 
                            entry = currentValue ; 
                            sellEntryInds.add(values.size()-1) ; 
                            ntrades ++ ; 
                        }
                    }        
                }
                else if(inBuy){
                    if(currentValue > mvg3Value && prevValue < mvg3Value){ // price crosses m3 going up
                        totalProfit += currentValue - entry - transactionCostPips ; 
                        estimatedTransactionCost += transactionCostPips ;  
                        buyExitInds.add(values.size()-1) ;
                        inBuy = false ; 
                        upl = 0 ; 
                    }                    
                }        
                else if(inSell){
                    if(currentValue < mvg3Value && prevValue > mvg3Value){ // price cross m3 going down 
                        totalProfit += entry-currentValue - transactionCostPips ; 
                        estimatedTransactionCost += transactionCostPips ;  
                        sellExitInds.add(values.size()-1) ; 
                        inSell = false ; 
                        upl = 0 ; 
                    }
                }    
            }
        } 
        public void calculateMvgs(double input){     
            if(values.size() > mvg1Period){
                double newmvg = 0 ; 
                for(int i=values.size()-mvg1Period;i<values.size();i++)
                    newmvg += values.get(i) ; 
                mvg1.add(newmvg/mvg1Period) ;                 
            }
            else mvg1.add(input) ; 
                  
            if(values.size() > mvg2Period){
                double newmvg = 0 ; 
                for(int i=values.size()-mvg2Period;i<values.size();i++)
                    newmvg += values.get(i) ; 
                mvg2.add(newmvg/mvg2Period) ;             
            }
            else mvg2.add(input) ; 
            
            if(values.size() > mvg3Period){
                double newmvg = 0 ; 
                for(int i=values.size()-mvg3Period;i<values.size();i++)
                    newmvg += values.get(i) ; 
                mvg3.add(newmvg/mvg3Period) ;             
            }
            else mvg3.add(input) ; 
        }
     }
    
class PlotAllTimeSeries extends JPanel implements Runnable, KeyListener{  
    JFrame jf ; 
    int WIDTH = 500 ; int HEIGHT = 500 ; 
    BufferedImage bim = new BufferedImage(WIDTH,HEIGHT,BufferedImage.TYPE_INT_ARGB) ; 
    Graphics2D g2 = bim.createGraphics() ;     
    public ArrayList<Double> values ;
    BasicStrategy1 trader ; 
    MultiStrat ms ; 
    int pointsToDisplay = 5000 ; 
    int currentStratIndex = 0 ;
     
    public PlotAllTimeSeries(MultiStrat ms){
        console.getOut().println("starting pats") ; 
        this.ms = ms ; 
    } 
    public void setTrader(int index){
        this.trader = ms.allStrats.get(index) ;     
        this.values = trader.values ; 
    }
    public void run(){}   
       
    public void render(){
        ms.sumProfits() ; 
        g2.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
        NumberFormat formatter = new DecimalFormat("#00000.00000") ;
        g2.setColor(Color.BLACK) ;
        g2.fill(new Rectangle2D.Double(0,0,500,500)) ;
        int startInd = 0 ; 
        if(values.size() < pointsToDisplay){
            startInd = 0 ;     
        }
        else {
            startInd = values.size() - pointsToDisplay ; 
        }
        double w = getWidth()-100 ; 
        double h = getHeight() ; 
        double xstep = w/(values.size()-startInd) ;
        double maxOrig = listMax(values.subList(startInd, values.size()-1)) ; 
        double minOrig = listMin(values.subList(startInd, values.size()-1)) ; 
        double max = maxOrig + (maxOrig-minOrig)/2 ; double min = minOrig - (maxOrig-minOrig)/2 ; 
        double ystep = h/(max-min);        
        // y axis
        g2.setColor(Color.LIGHT_GRAY) ;
        g2.draw(new Line2D.Double(w,0,w,h));
        g2.draw(new Line2D.Double(0,h-h/4,w+100,h-h/4));
        double nPipTicks = 10 ; 
        double axisIncr = (maxOrig-minOrig)/nPipTicks ; 
        g2.setFont(new Font("TimesRoman",Font.BOLD,12));
        for(int i=1;i<nPipTicks;i++){
            double yVal = minOrig + axisIncr*i ; 
            double yPos = (max-yVal)*ystep ; 
            g2.setColor(Color.DARK_GRAY) ;g2.draw(new Line2D.Double(0,yPos,w+8,yPos)) ;
            g2.setColor(Color.LIGHT_GRAY) ;g2.drawString(""+formatter.format(yVal), (int)w+10, (int)yPos+3);
        }            
        // x-axis
        Font font = new Font(null, Font.BOLD, 12) ;    
        AffineTransform affineTransform = new AffineTransform() ;
        affineTransform.rotate(Math.toRadians(55), 0, 0) ;
        Font rotatedFont = font.deriveFont(affineTransform) ;
        g2.setFont(rotatedFont) ;
        double nXPoints = 15 ; 
        double xIncr = w/nXPoints ; 
        List<String> dateSubList = trader.dates.subList(startInd, values.size()-1) ; 
        double dateIncr = dateSubList.size()/nXPoints ; 
        
        for(int i=0;i<nXPoints;i++){
            int yaxe = (int)((max-minOrig)*ystep) ; int xaxe = (int)(xIncr*i) ; 
            g2.setColor(Color.LIGHT_GRAY) ; g2.drawString(dateSubList.get((int)(dateIncr*i)),xaxe,yaxe+15);
            g2.setColor(Color.DARK_GRAY) ; g2.draw(new Line2D.Double(xaxe,0,xaxe,yaxe+3));
        }       
        g2.setColor(Color.GRAY) ; double lastY = 0 ; double lastX = 0 ;
        for(int i=startInd+1;i<values.size();i++){
            double x1 = (i-startInd-1)*xstep ; double x2 = (i-startInd)*xstep ; 
            double y1 = (max-values.get(i-1))*ystep ; 
            double y2 = (max-values.get(i))*ystep ; 
            g2.draw(new Line2D.Double(x1,y1,x2,y2)) ;
            lastX = x2 ; lastY = y2 ; 
        }    
        g2.setColor(Color.YELLOW) ;
        g2.fill(new Ellipse2D.Double(lastX-2,lastY-2,4,4)) ;
        g2.setColor(Color.WHITE) ; 
        for(int i=startInd+1;i<trader.mvg1.size();i++){
            double x1 = (i-startInd-1)*xstep ; double x2 = (i-startInd)*xstep ; 
            double y1 = (max-trader.mvg1.get(i-1))*ystep ; 
            double y2 = (max-trader.mvg1.get(i))*ystep ; 
            g2.draw(new Line2D.Double(x1,y1,x2,y2)) ;
        }    
        g2.setColor(Color.BLUE) ; 
        for(int i=startInd+1;i<trader.mvg2.size();i++){
            double x1 = (i-startInd-1)*xstep ; double x2 = (i-startInd)*xstep ; 
            double y1 = (max-trader.mvg2.get(i-1))*ystep ; 
            double y2 = (max-trader.mvg2.get(i))*ystep ; 
            g2.draw(new Line2D.Double(x1,y1,x2,y2)) ;
        }
        
        g2.setColor(Color.MAGENTA) ; 
        for(int i=startInd+1;i<trader.mvg3.size();i++){
            double x1 = (i-startInd-1)*xstep ; double x2 = (i-startInd)*xstep ; 
            double y1 = (max-trader.mvg3.get(i-1))*ystep ; 
            double y2 = (max-trader.mvg3.get(i))*ystep ; 
            g2.draw(new Line2D.Double(x1,y1,x2,y2)) ;
        }
        for(int i=0;i<trader.buyEntryInds.size();i++){
            int indice = trader.buyEntryInds.get(i) ; 
            g2.setColor(Color.GREEN) ;
            double x1 = (indice-startInd)*xstep ; 
            double y1 = (max-values.get(indice))*ystep ; 
            g2.draw(new Ellipse2D.Double(x1-4,y1-4,8,8));    
            if(trader.buyExitInds.size()==trader.buyEntryInds.size() || i<trader.buyEntryInds.size()-1){
                g2.setColor(Color.GREEN) ;
                int indice2 = trader.buyExitInds.get(i) ; 
                double x2 = (indice2-startInd)*xstep ; 
                double y2 = (max-values.get(indice2))*ystep ; 
                g2.fill(new Ellipse2D.Double(x2-4,y2-4,8,8)) ;        
                g2.setColor(Color.CYAN);
                g2.draw(new Line2D.Double(x1,y1,x2,y2)) ;
            }
        }
        for(int i=0;i<trader.sellEntryInds.size();i++){
            int indice = trader.sellEntryInds.get(i) ; 
            g2.setColor(Color.RED) ;
            double x1 = (indice-startInd)*xstep ; 
            double y1 = (max-values.get(indice))*ystep ; 
            g2.draw(new Ellipse2D.Double(x1-4,y1-4,8,8));    
            if(trader.sellEntryInds.size()==trader.sellExitInds.size() || i<trader.sellEntryInds.size()-1){
                g2.setColor(Color.RED) ;
                int indice2 = trader.sellExitInds.get(i) ; 
                double x2 = (indice2-startInd)*xstep ; 
                double y2 = (max-values.get(indice2))*ystep ; 
                g2.fill(new Ellipse2D.Double(x2-4,y2-4,8,8)) ;        
                g2.setColor(Color.ORANGE);
                g2.draw(new Line2D.Double(x1,y1,x2,y2)) ;
            }
        }    
        g2.setColor(Color.LIGHT_GRAY);
        g2.fill(new Rectangle2D.Double(0,0,500,h/4));
        g2.setFont(new Font("TimesRoman", Font.PLAIN, 12)) ;
        if(trader.totalProfit>=0)
            g2.setColor(Color.BLACK) ;
        else g2.setColor(Color.RED) ;
        g2.drawString("totalProfit: " + formatter.format(trader.totalProfit/trader.scaleFactor), 20, 15);
        g2.setColor(Color.BLACK) ;     g2.drawString("totalProfit: ", 20, 15);       
        if(trader.upl>=0){
            g2.setColor(Color.BLACK);
            g2.drawString("UPL: " + formatter.format(trader.upl), 20, 30);
        }
        else if(trader.upl<0){
            g2.setColor(Color.RED);
            g2.drawString("UPL: " + formatter.format(trader.upl), 20, 30);
        }
        g2.setColor(Color.BLACK) ;
        g2.drawString("UPL: ", 20, 30);
        g2.drawString("transactionCosts:" + formatter.format(trader.estimatedTransactionCost), 20,45) ;           
        // all profits (net of all strategies)
        if(ms.totalProfit>0)
            g2.setColor(Color.BLACK) ;
        else g2.setColor(Color.RED) ;
        g2.drawString("allNetProfits(pips) : " + formatter.format(ms.totalProfit), 20, 60) ;
        g2.setColor(Color.BLACK) ; g2.drawString("allNetProfits(pips) : ", 20, 60) ;  
        g2.drawString("allTransactionCosts(pips) :" + formatter.format(ms.totalTradeCost), 20,75) ;           
        g2.setFont(new Font("TimesRoman", Font.BOLD, 25)) ;
        g2.drawString(trader.pair, 250, 70) ;
        g2.setFont(new Font("TimesRoman", Font.PLAIN, 15)) ;
        g2.drawString("transactionPerTrade: "+formatter.format(trader.transactionCostPips), 250, 30) ;
        g2.drawString("numberTrades: "+(trader.ntrades), 250, 42) ;
    }
    
    public void paintComponent(Graphics g){
        super.paintComponent(g);
        Graphics2D g2 = (Graphics2D)g ;
        g2.drawImage(bim,0,0,null) ;
    }
    
    public void initFrame(){
        jf = new JFrame() ; 
        jf.setPreferredSize(new Dimension(WIDTH+25,HEIGHT+45));
        jf.add(this) ; 
        jf.setDefaultCloseOperation(JFrame.HIDE_ON_CLOSE) ;        
        jf.setVisible(true) ;
        jf.addKeyListener(this) ;
        jf.pack() ;     
    }

    public void keyTyped(KeyEvent e) {}

    public void keyPressed(KeyEvent e) {
        System.out.println("key pressed") ; 
        if(e.getKeyCode() == KeyEvent.VK_RIGHT){
            if(currentStratIndex + 1 == ms.allStrats.size())
                currentStratIndex = 0 ; 
            else currentStratIndex ++ ; 
            
            setTrader(currentStratIndex) ; 
            render() ; 
            repaint() ; 
        }        
        if(e.getKeyCode() == KeyEvent.VK_LEFT){
            if(currentStratIndex - 1 == -1)
                currentStratIndex = ms.allStrats.size()-1 ; 
            else currentStratIndex -- ;         
            setTrader(currentStratIndex) ; 
            render() ; 
            repaint() ; 
        }
        if(e.getKeyCode() == KeyEvent.VK_DOWN){
            if(pointsToDisplay/2 < 25){
                if(pointsToDisplay-1 > 0)
                    pointsToDisplay-= 1 ; 
            }
            else pointsToDisplay/= 2 ;         
            render() ; 
            repaint() ; 
        }
        if(e.getKeyCode() == KeyEvent.VK_UP){
            if(pointsToDisplay*2 > values.size())
                pointsToDisplay = values.size() ; 
            else pointsToDisplay*= 2 ;         
            render() ; 
            repaint() ; 
        }     
    }
    public void keyReleased(KeyEvent e){}     
} 
    public double listMax(List<Double> input){
       double max = -999999999 ; 
       for(int i=0;i<input.size();i++)
           if(input.get(i) > max)
               max = input.get(i) ;
       return max ;        
    }
    public double listMin(List<Double> input){
       double min = 999999999 ; 
       for(int i=0;i<input.size();i++)
           if(input.get(i) < min)
               min = input.get(i) ; 
       return min ; 
    }
    public  ArrayList<double[]> getOverheadMvgParams(String inputPath){
        ArrayList<double[]> array = new ArrayList<double[]>() ; 
         File f = new File(inputPath) ;
        try {    
            BufferedReader in = new BufferedReader(new FileReader(f));
            
            for (String x = in.readLine(); x != null ; x = in.readLine()){
                    String[] arr = x.split(",") ;                 
                    System.out.println("string = " + x) ; 
                    double[] mvgparams = {Double.parseDouble(arr[0]),Double.parseDouble(arr[1]),Double.parseDouble(arr[2]),Double.parseDouble(arr[3])} ; 
                    array.add(mvgparams) ; 
            }                
            in.close() ;
           } catch (IOException e) {
            console.getOut().println("File I/O error!");
        }
        return array ; 
    }
    
    public HashMap<String,Double> getSpreadFile(String pathAndName){
        HashMap<String,Double> map = new HashMap<String,Double>() ; 
        File f = new File(pathAndName) ;
        try {    
            BufferedReader in = new BufferedReader(new FileReader(f));    
            for (String x = in.readLine(); x != null ; x = in.readLine()){
                    String[] arr = x.split(",") ;                            
                    map.put(arr[0],Double.parseDouble(arr[1])) ; 
            }                
            in.close() ;
           } catch (IOException e) {
            console.getOut().println("IO Exception!") ; 
        }    
        return map ; 
    }
    
    public ArrayList<String> getAvailableCurrencies(String dirName){
        ArrayList<String> currs = new ArrayList<String>() ; 
        File dir = new File(dirName) ;
        File [] files = dir.listFiles(new FilenameFilter() {
            public boolean accept(File dir, String name) {
                return name.startsWith("txt_") ;
            }
        });
        for (File f : files) {
            String[] names = f.getName().split("-") ; 
            console.getOut().println(names[1].substring(0,3) + "/" + names[1].substring(3,6)) ;   
            currs.add(names[1].substring(0,3) + "/" + names[1].substring(3,6)) ; 
        }
        return currs ; 
    }
    
}
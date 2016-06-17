//  V 1.5
//  Favs.swift
//  Guía con buscador
//
//  Created by Arístides Guimerá on 12/5/16.
//  Copyright © 2016 Arístides Guimerá. All rights reserved.
//

import UIKit

class Favs: UIViewController, UISearchBarDelegate{
    
    //Referencias de la UI
    @IBOutlet weak var tablaVista: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var barraBusqueda: UISearchBar!
    let guia: ViewController = ViewController()
    
    
    //Declaramos las variables necesarias
    var arrayCompleta:[[String]] = [[String]]()
    var arrayCompletaFav:[[String]] = [[String]]()
    var arraySeguridad:[[String]] = [[String]]()
    var searchActive : Bool = false
    var filtered:[String] = []
    var tableData:Array< String > = Array < String > ()
    var tablePhone:Array< String > = Array < String > ()
    var tableMobile:Array< String > = Array < String > ()
    var imagenFav:Array = ["estrella.png","estrellaFav.png"]
    let textCellIdentifier = "cell"
    let rutaJSon:String = "" //Ruta del JSon
    let baseDatos = NSUserDefaults.standardUserDefaults()
    var arrayNombre: Array = [""]
    var arrayTel: Array = [""]
    var arrayMov: Array = [""]
    var arrayNombreFav: Array = ["Favoritos"]
    var arrayTelFav: Array = ["0000"]
    var arrayMovFav: Array = ["0000"]
    
    
    
    //******************************************************************
    //* Contructor                                                     *
    //******************************************************************
    override func viewDidLoad() {
        super.viewDidLoad()
        arrayCompleta = guia.rescataRegistrosFav()
        barraBusqueda.delegate = self
        
        //Instanciamos para poder desmarcar el buscador
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //******************************************************************
    //* Métodos tabla obligatorios                                     *
    //******************************************************************
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered.count
        }
        return arrayCompleta.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as! MiCustomCell
        
        if(searchActive){
            
            cell.nombreCelda?.text = filtered[indexPath.row]
            
            let array = guia.rescataRegistros()
            
            
            for (index, _) in array.enumerate() {
                
                if(array[index][0] == filtered[indexPath.row]){
                    
                    let num = array[index][1]
                    let num2 = array[index][2]
                    
                    cell.numPrincipalCelda?.setTitle((num ), forState: .Normal)
                    
                    if(num2 == ""){
                        cell.numSecundarioCelda?.setTitle("", forState: .Normal)
                    }else{
                        cell.numSecundarioCelda?.setTitle((num2 ), forState: .Normal)
                        cell.imagenMovil.image = UIImage(named: "mov.png")
                    }
                    
                }
                
                
                
            }
            
        } else {
            
            let row = indexPath.row
            cell.tag = indexPath.row
            cell.nombreCelda?.text = arrayCompleta[row][0]
            
            
            cell.numPrincipalCelda?.tag = indexPath.row
            cell.numPrincipalCelda.setTitle(arrayCompleta[indexPath.row][1], forState: .Normal)
            cell.numPrincipalCelda.addTarget(self, action: #selector(ViewController.avisoTel(_:)), forControlEvents: .TouchUpInside)
            
            cell.numSecundarioCelda.tag = indexPath.row
            cell.numSecundarioCelda.setTitle(arrayCompleta[row][2], forState: .Normal)
            
            
            cell.numSecundarioCelda.addTarget(self, action: #selector(ViewController.avisoSecundario(_:)), forControlEvents: .TouchUpInside)
            
            
            cell.botonFav.tag = indexPath.row
            cell.botonFav.addTarget(self, action: #selector(ViewController.indiceColumna(_:)), forControlEvents: .TouchUpInside)
            
            
                cell.botonFav.setImage(UIImage(named: imagenFav[1])!, forState: .Normal)
                cell.imagenMovil.image = nil
            
            if(arrayCompleta[row][2] == ""){
                cell.imagenMovil.image = nil
            }else{
                cell.imagenMovil.image = UIImage(named: "mov.png")
            }
            
            
        }
        return cell
        
    }
    
    
    
    
    //********************************************************************
    //* Borra favoritos                                                  *
    //********************************************************************
    @IBAction func indiceColumna(sender: UIButton) {
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        let cell = tablaVista.cellForRowAtIndexPath(indexPath) as! MiCustomCell!
        _ = cell.tag
        let point = tablaVista.convertPoint(CGPointZero, fromView: sender)
        let nombre = cell.getNombreCelda()
        if let indexPath = tablaVista.indexPathForRowAtPoint(point) {
            print(indexPath.row)
                    let alertaLlamada = UIAlertController(title: "Borrar favorito", message: "¿Quieres quitar a \(nombre) de favoritos?", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alertaLlamada.addAction(UIAlertAction(title: "Sí" , style: UIAlertActionStyle.Cancel ,handler: {alerAction in
                        print("quitado")
                        
                        
                        cell.botonFav.setImage(UIImage(named: self.imagenFav[0])!, forState: .Normal)
                        
                        var array = self.guia.rescataRegistrosFav()
                        
                        let conatador:Int = array.count
                        //conatador = conatador - 1
                        
                        
                        
                        for index in 0...conatador - 1{
                            print("Estoy borrando \(index)")
                            if(array[index][0].isEqual(cell.getNombreCelda() )){
                                
                                
                                array.removeAtIndex(index)
                                self.guia.borraFav()
                                self.guia.guardaEnMemoriaFav(array)
                                
                                break;
                            }
                        }
      
                    }))
                    
                    alertaLlamada.addAction(UIAlertAction(title: "No" , style: UIAlertActionStyle.Default ,handler: {alerAction in
                        print("noquitado")
                        
                        
                    }))
                    
                    
                    self.presentViewController(alertaLlamada, animated: true, completion: nil)

        }
    }
    
    
    //******************************************************************
    //* Funciones para hacer saltar los avisos y llamar o volver atrás *
    //******************************************************************
    
    @IBAction func avisoTel(sender: UIButton){
        
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        let cell = tablaVista.cellForRowAtIndexPath(indexPath) as! MiCustomCell!
        let row = cell.tag
        let nombre = cell.getNombreCelda()
        
        //Con este if saco el valor del botón, para llamar a el número correcto.
        if let text = sender.titleLabel?.text {
            print("1-----\(text)")
        }
        
        print("2-------- \(arrayCompleta[row][0])")
        
        let alertaLlamada = UIAlertController(title: "Llamar", message: "¿Quieres llamar a \(nombre) ?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertaLlamada.addAction(UIAlertAction(title: "Salir" , style: UIAlertActionStyle.Cancel ,handler: {alerAction in
            print("Pulsado el boton de Salir")
            
        }))
        
        alertaLlamada.addAction(UIAlertAction(title: "Llamar" , style: UIAlertActionStyle.Default ,handler: {alerAction in
            print("Pulsado el boton de Llamar")
            let formatedNumber = cell.getNumPrincipal()
            let phoneUrl = "tel://\(formatedNumber)"
            let url:NSURL = NSURL(string: phoneUrl)!
            UIApplication.sharedApplication().openURL(url)
        }))
        
        
        self.presentViewController(alertaLlamada, animated: true, completion: nil)
        
    }
    
    @IBAction func avisoSecundario(sender: UIButton){
        
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        let cell = tablaVista.cellForRowAtIndexPath(indexPath) as! MiCustomCell!
        
        let row = cell.numSecundarioCelda.tag
        let nombre = cell.getNombreCelda()
        
        
        if(arrayCompleta[row][2] == ""){
            
        }else{
            
            let alertaLlamada = UIAlertController(title: "Llamar", message: "¿Quieres llamar a \(nombre) ?", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertaLlamada.addAction(UIAlertAction(title: "Salir" , style: UIAlertActionStyle.Cancel ,handler: {alerAction in
                print("Pulsado el boton de Salir")
            }))
            
            alertaLlamada.addAction(UIAlertAction(title: "Llamar" , style: UIAlertActionStyle.Default ,handler: {alerAction in
                print("Pulsado el boton de Llamar")
                
                let formatedNumber = cell.getNumSecundario()
                let phoneUrl = "tel://\(formatedNumber)"
                let url:NSURL = NSURL(string: phoneUrl)!
                UIApplication.sharedApplication().openURL(url)
            }))
            
            
            self.presentViewController(alertaLlamada, animated: true, completion: nil)
            
        }
        
    }
    

    
    //*****************************************************************
    //* Recorre el JSon y asigna los valores necesarios en las arrays *
    //*****************************************************************
 
    func limpiaTabla(){
        arrayCompleta.removeAll()
        tablaVista.reloadData()
        
    }

    @IBAction func cambiaPestaña(sender: AnyObject) {
        
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("Agenda") as UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
            break;
        case 1:
            break
        default:
            break;
        }
    }
    
    func posicionSegmented() -> Int{
        return segmentedControl.selectedSegmentIndex
    }
    

    
    //********************************************************
    //* Funciones para el uso correcto del buscador dinámico *
    //********************************************************
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    //ARREGLARBUSCADOR
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        tableData.removeAll()
        for(key, _) in arrayCompleta.enumerate(){
            tableData.append(arrayCompleta[key][0])
        }
        
        filtered = tableData.filter({ (text) -> Bool in
            print("----------------\(searchText)")
            let tmp: NSString = text
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
            
        })
        
        if(filtered.count == 0){
            if(searchText.isEmpty){
                searchActive = false
            }else{
                searchActive = true
            }
            
            
        } else {
            
            searchActive = true;
            
        }
        self.tablaVista.reloadData()
    }
    
    
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
  
    
    
}

    
    


// Versión con buscador guay

//  ViewController.swift
//  AgendaFinal
//
//  Created by Arístides Guimerá on 10/5/16.
//  Copyright © 2016 Arístides Guimerá. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{

    //Referencias de la UI
    @IBOutlet weak var barraBusqueda: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tablaVista: UITableView!
    
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
    let rutaJSon:String = "" //Ruta JSON
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
        
        
        recorreJSon()
        delegaciones()
        asignaImagen()
        
        //Instanciamos para poder desmarcar el buscador
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    
    
    //******************************************************************
    //* Asigna la imagen de estrella normal                            *
    //******************************************************************
    func asignaImagen(){
        let boton  = UIButton(type: .Custom)
        if let image = UIImage(named: "estrella.png") {
            boton.setImage(image, forState: .Normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //******************************************************************
    //* Métodos tabla obligatorios                                     *
    //******************************************************************
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 //Para poner más secciones aquí.
    }
    
    //Tamaño de la tabla
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered.count
        }
        return arrayCompleta.count
    }
    
    //Configura las celdas
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as! MiCustomCell
        
        if(searchActive){
            
            cell.nombreCelda?.text = filtered[indexPath.row]
            
            let array = rescataRegistros()
            
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
        print("row: \(row)")
        
        cell.nombreCelda?.text = arrayCompleta[row][0]
        
        cell.numPrincipalCelda?.tag = indexPath.row
        cell.numPrincipalCelda.setTitle(arrayCompleta[indexPath.row][1], forState: .Normal)
        cell.numPrincipalCelda.addTarget(self, action: #selector(ViewController.avisoTel(_:)), forControlEvents: .TouchUpInside)
        
        cell.numSecundarioCelda.tag = indexPath.row
        cell.numSecundarioCelda.setTitle(arrayCompleta[row][2], forState: .Normal)
        
        
        cell.numSecundarioCelda.addTarget(self, action: #selector(ViewController.avisoSecundario(_:)), forControlEvents: .TouchUpInside)
        
        
        cell.botonFav.tag = indexPath.row
        cell.botonFav.addTarget(self, action: #selector(ViewController.indiceColumna(_:)), forControlEvents: .TouchUpInside)
        
        if posicionSegmented() == 1 {
            cell.botonFav.setImage(UIImage(named: imagenFav[1])!, forState: .Normal)
            cell.imagenMovil.image = nil
        }else{
            
            let favs = rescataRegistrosFav()
            
            if(arrayCompleta[row][2] == ""){
                cell.imagenMovil.image = nil
            }else{
                cell.imagenMovil.image = UIImage(named: "mov.png")
            }
            
            
            if(favs.count > 0){
                
                
                for i in 0...favs.count-1
                {
                    for j in 0...favs[i].count-1
                    {
                        
                        if(favs[i][j] == cell.getNombreCelda()){
                            cell.botonFav.setImage(UIImage(named: imagenFav[1])!, forState: .Normal)
                            
                            return cell
                        }
                        
                        
                        
                    }
                }
                
            
            }
    
                cell.botonFav.setImage(UIImage(named: imagenFav[0])!, forState: .Normal)
            }
    
        }
        return cell
    }
    
    
    
    //********************************************************************
    //* Comprueba si está marcado favorito, y si es así lo puedes borrar.*
    //* Si no está marcado te lo añade a favoritos                       *
    //********************************************************************
    @IBAction func indiceColumna(sender: UIButton) {
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        let cell = tablaVista.cellForRowAtIndexPath(indexPath) as! MiCustomCell!
        let row = cell.tag
        let point = tablaVista.convertPoint(CGPointZero, fromView: sender)
        let nombre = cell.getNombreCelda()
        
        if let indexPath = tablaVista.indexPathForRowAtPoint(point) {
            print(indexPath.row)
            if(posicionSegmented() == 0){
                if cell.botonFav.currentImage!.isEqual(UIImage(named: "estrellaFav.png")){
                    
                    let alertaLlamada = UIAlertController(title: "Borrar favorito", message: "¿Quieres quitar a \(nombre) de favoritos?", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alertaLlamada.addAction(UIAlertAction(title: "Sí" , style: UIAlertActionStyle.Cancel ,handler: {alerAction in
                        print("quitado")
                        
                        
                        cell.botonFav.setImage(UIImage(named: self.imagenFav[0])!, forState: .Normal)
                        
                        var array = self.rescataRegistrosFav() 
                        
                        let conatador:Int = array.count
                        
                        for index in 0...conatador - 1{
                            print("Estoy borrando \(index)")
                            if(array[index][0].isEqual(cell.getNombreCelda() )){
                                
                                
                                array.removeAtIndex(index)
                                self.borraFav()
                                self.guardaEnMemoriaFav(array)
                                break
                            }
                        }
                        
                    }))
                    
                    alertaLlamada.addAction(UIAlertAction(title: "No" , style: UIAlertActionStyle.Default ,handler: {alerAction in
                        print("noquitado")
                        
                    }))
                    
                    self.presentViewController(alertaLlamada, animated: true, completion: nil)

                }else{
                    sender.setImage(UIImage(named: imagenFav[1])!, forState: .Normal)
                    
                    //AÑADE A FAVORITOS
                    
                    arrayCompletaFav = rescataRegistrosFav() 
                    
                    self.arrayCompletaFav.append(arrayCompleta[row])
                    
                    guardaEnMemoriaFav(arrayCompletaFav)
                    
                }
                
            }
            
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
        /*if let text = sender.titleLabel?.text {
            print("1-----\(text)")
        }*/
        
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

    
    
    //********************************************************
    //* Delegaciones correspondientes                        *
    //********************************************************
    
    func delegaciones(){
        barraBusqueda.delegate = self
        tablaVista.delegate = self
        tablaVista.dataSource = self
    }
    
    
    
    //*****************************************************************
    //* Recorre el JSon y asigna los valores necesarios en las arrays *
    //*****************************************************************
    
    func recorreJSon(){
        let requestURL: NSURL = NSURL(string: rutaJSon)!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                self.arrayNombre.removeAll()
                self.arrayTel.removeAll()
                self.arrayMov.removeAll()
                do{
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    
                    if let contactos = json["contactos"] as? [[String: AnyObject]] {
                        
                        for contacto in contactos {
                            
                            if let tel = contacto["tf_numero1"] as? String {
                                
                                if let nom = contacto["tf_nombre"] as? String {
                                    self.tableData.append(nom)
                                    self.tablePhone.append(tel)
                                    
                                    self.arrayNombre.append(nom)
                                    self.arrayTel.append(tel)
                                    
                                    if let movil = contacto["tf_numero2"] as? String{
                                        self.tableMobile.append(movil)
                                        
                                        self.arrayMov.append(movil)
                                        
                                        self.arrayCompleta.append([nom, tel, movil])
                                    }else{
                                        self.tableMobile.append("")
                                        
                                        self.arrayMov.append("")
                                        
                                        self.arrayCompleta.append([nom, tel, ""])
                                    }
                                }
                                
                            }
                        }
                        
                        self.guardaEnMemoria(self.arrayCompleta)
                        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                            self.tablaVista.reloadData()
                        }
                    }
                    
                }catch {
                    print("Error with Json: \(error)")
                    
                }
                
            }else{
                self.limpiaTabla()
                self.arrayCompleta = self.rescataRegistros()
            }
            
            
        }
        task.resume()
    }
    
    
    //******************************************************************
    //* Muestra los favoritos                                          *
    //******************************************************************
   /* func muestraFavoritos(){
        let aRecorrer = rescataRegistrosFav()
        
        for (index, _) in aRecorrer.enumerate() {
            
            
        
            if(aRecorrer[index] == [""]){
                print ("vacio")
            }else{
                self.arrayCompleta.append(aRecorrer[index] )
            }
            print("muestraFavoritos: \(aRecorrer[index])")
        }
        
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.tablaVista.reloadData()
            
        }
        
    }*/
    
    //******************************************************************
    //* Recarga la tabla para evitar duplicas                          *
    //******************************************************************
    func limpiaTabla(){
        arrayCompleta.removeAll()
        tablaVista.reloadData()
    }
    
    
    //******************************************************************
    //* Controlador del segmented Controller                           *
    //******************************************************************
    @IBAction func cambiaPestaña(sender: AnyObject) {
        
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            limpiaTabla()
            recorreJSon()
            break
        case 1:
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("Favo") as! Favs
            self.presentViewController(vc, animated: true, completion: nil)
        default:
            break;
        }
    }
    
    func posicionSegmented() -> Int{
        return segmentedControl.selectedSegmentIndex
    }
    
    
    
    
    //******************************************************************
    //* Guardados y rescates de memoria                                *
    //******************************************************************
    func guardaEnMemoria(miArray: [[String]]) {
        NSUserDefaults.standardUserDefaults().setObject(miArray, forKey:"MIARRAY")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func rescataRegistros() -> [[String]]{
        return NSUserDefaults.standardUserDefaults().arrayForKey("MIARRAY")! as! [[String]]
    }

    func guardaEnMemoriaFav(miArrayFAV: [[String]]) {
        NSUserDefaults.standardUserDefaults().setObject(miArrayFAV, forKey:"MIARRAYFAV")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func rescataRegistrosFav() -> [[String]]{
        
        let array = [[String]]()
        
        if((NSUserDefaults.standardUserDefaults().arrayForKey("MIARRAYFAV")) != nil){
           return NSUserDefaults.standardUserDefaults().arrayForKey("MIARRAYFAV")! as! [[String]]
        }
        
        return array
    }
    
    func borraFav(){
        NSUserDefaults.standardUserDefaults().removeObjectForKey("MIARRAYFAV")
        
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


    //******************************************************************
    //* Esconde el teclado al pulsar fuera de la barra de búsqueda     *
    //******************************************************************
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }




}


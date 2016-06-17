//
//  MiCustomCell.swift
//  AgendaFinal
//
//  Created by Arístides Guimerá on 10/5/16.
//  Copyright © 2016 Arístides Guimerá. All rights reserved.
//

import UIKit

//*********************************************************************
//* Clase necesaria para la customización de la celda, si se quisiera *
//* añadir algo más a la celda se tendría que declarar aquí           *
//*********************************************************************


class MiCustomCell: UITableViewCell {
    
    
    @IBOutlet weak var nombreCelda: UILabel!
    @IBOutlet weak var numSecundarioCelda: UIButton!
    @IBOutlet weak var numPrincipalCelda: UIButton!
    @IBOutlet weak var botonFav: UIButton!
    @IBOutlet weak var imagenMovil: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    func getNombreCelda()->String{
        
        return nombreCelda.text!
    }
    
    func getNumPrincipal()->String{
        
        return (numPrincipalCelda.titleLabel?.text)!
    }
    
    func getNumSecundario()->String{
        print(numSecundarioCelda.titleLabel?.text)
        if (numSecundarioCelda.titleLabel?.text) == nil{
            
            return ""
        }else{
            return (numSecundarioCelda.titleLabel?.text)!
        }
    }

    
}

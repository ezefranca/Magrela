//
//  DispositivosTableViewController.swift
//  HackaBike
//
//  Created by Ezequiel on 4/16/16.
//  Copyright © 2016 Ezequiel. All rights reserved.
//


import UIKit
import CoreBluetooth

var activeCentralManager: CBCentralManager? // O que está controlando o Bluetooth
var peripheralDevice: CBPeripheral? // Dispositivo que será conectado pelo Bluetooth
var devices: Dictionary<String, CBPeripheral> = [:] // Lista de todos os devices que estão proximos
var deviceName: String? //Nome do Device
var devicesRSSI = [NSNumber]() //Código do Device que será conectado
var devicesServices: CBService! // Servicos do que o dispositivo vai fazer ao se conectar com o celular
var deviceCharacteristics: CBCharacteristic! //Guarda informações importantes sobre o device que será conectado
var abriuTela:Bool = false

@objc protocol DispositivosBluetoothProtocol {
    func retornaBluetooth(retorno: String)
    func desconectou()
}

// é Importados todos os delegates para serem colocados na tableView
class DevicesVC: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    weak var delegate: DispositivosBluetoothProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Singleton.sharedInstance.dispositivosBluetooth = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    //Acontece quando a tela ainda não carregou os elementos
    override func viewWillAppear(animated: Bool) {
        
        abriuTela = false
        // Limpa os elementos do dicionario
        devices.removeAll(keepCapacity: false)
        devicesRSSI.removeAll(keepCapacity: false)
        
        // Inicializa o Manager/Dispositivo mestre (meu iphone) Bluetooth
        activeCentralManager = CBCentralManager(delegate: self, queue: nil)
        
        //Inicia a tableView com conteudo limpo
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(DevicesVC.update), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    
    
    // Atualizador
    func update(){
        // Limpa todos os elementos do dicionario
        devices.removeAll(keepCapacity: false)
        devicesRSSI.removeAll(keepCapacity: false)
        
        // Inicializa o Manager/Dispositivo metre (meu iPhone)
        activeCentralManager = CBCentralManager(delegate: self, queue: nil)
        
        //Para de atualizar
        self.refreshControl?.endRefreshing()
    }
    
    //Evento quando o estado do iPhone do Bluetooth mudar
    func centralManagerDidUpdateState(central: CBCentralManager) {
        //Se o bluetooth estiver ligado
        if central.state == CBCentralManagerState.PoweredOn {
            // Escaneia todos os dispositivos que ele pode alcançar
            central.scanForPeripheralsWithServices(nil, options: nil)
            print("Searching for BLE Devices")
        }
            // Se o bluetooth estiver desligado
        else {
            // Can have different conditions for all states if needed - print generic message for now
            print("Bluetooth switched off or not initialized")
        }
        
        
    }
    
    // Procura dispositivos e coloca na lista
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        // Verifica se o dispositivo é nulo
        // Verifica se o dispositivo que vou me conectar é nulo
        
        //Pego o UUID do dispositivo que vou me conectar
        if let name = peripheral.name {
            
            
            
            //if name == "CafeBLE" {
                
                // Preenche o dicionario atraves do UUID como indice, com o dado do periferico(BLE)
                if(devices[name] == nil) {
                    devices[name] = peripheral
                    devicesRSSI.append(RSSI) // Adiciona na lista da tableview
                    self.tableView.reloadData()
                }
            //}
            
            
        }
    }
    
    // Descobre os tipos de servicos do dispositivo que vou me conectar (BLE Arduino)
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        // Verifica se o dispositivo é nulo
        //Verifica se o dispositivo que vou me conectar é nulo
        // Descobre os servicos deste dispositivo
        if let peripheralDevice = peripheralDevice{
            peripheralDevice.discoverServices(nil)
            // Muda o texto da navigation Controller
            if let _ = navigationController {
                navigationItem.title = "Connected to \(deviceName)"
            }
        }
    }
    
    // Método sobrecarregado de periféricos
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        // Itera no vetor de servicos de um dispositivo especifico
        for service in peripheral.services! {
            let thisService = service as CBService
            
            // Mostra a caracteristicas de cada servico
            peripheral.discoverCharacteristics(nil, forService: thisService)
            if let _ = navigationController{
                navigationItem.title = "Discovered Service for \(deviceName)"
            }
        }
    }
    
    // Quando discobre as caracteristicas do periférico, ultimo método a ser chamado pela conexão com o BLE
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        //Verifica se o periférico é nulo
        // Verifica se os servicos deste periferico sao nulos
        // Verifica o UUID e cada caracteristica dos servicos
        // check the uuid of each characteristic to find config and data characteristics
        for charateristic in service.characteristics! {
            let thisCharacteristic = charateristic
            // Notifica se tem tem alguma caracteristica nova
            peripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            
            //Muda o titulo da navBar
            if let _ = navigationController{
                navigationItem.title = "Discovered Characteristic for \(deviceName)"
            }
            deviceCharacteristics = thisCharacteristic
        }
        
        
        if(!abriuTela){
            abriuTela = true
            performSegueWithIdentifier("MapKitVC", sender: self);
        }        
    }
    
    // Quando é recebido algo do Device - Retorno
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        let ret = NSString(data:characteristic.value!, encoding:NSUTF8StringEncoding) as! String
        
        self.delegate?.retornaBluetooth(ret)
        
        print("Retorno - \(ret)")
    }
    
    //Cancela a conexao
    func cancelConnection(){
        if let activeCentralManager = activeCentralManager{
            print("Died!")
            if let peripheralDevice = peripheralDevice{
                //println(peripheralDevice)
                activeCentralManager.cancelPeripheralConnection(peripheralDevice)
            }
        }
    }
    
    // Se desconectar comeca a procurar mais uma vez
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Disconnected")
        
        
        self.delegate?.desconectou()
        //Caso desconectar chamar o delegate
        central.scanForPeripheralsWithServices(nil, options: nil)
        
        
    }
    
    //Escreve um valor novo no BLe
    class func writeValue(data: String){
        
        let data = (data as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        
        if let peripheralDevice = peripheralDevice {
            
            if let deviceCharacteristics = deviceCharacteristics {
                
                //Pega a String e manda para o arduino
                peripheralDevice.writeValue(data!, forCharacteristic: deviceCharacteristics, type: CBCharacteristicWriteType.WithResponse)
                
                
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return devices.count
    }
    
    //Preenche a tableView
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Pega a celula
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CustomCell!
        
        // Coloca os valores do dicionario (devices) em uma variavel
        let discoveredPeripheralArray = Array(devices.values.lazy)
        
        
        // Verifica se a celula é nula
        if let cell = cell {
            //Procura no vetor de valores de devices o nome dos devices
            if let name = discoveredPeripheralArray[indexPath.row].name {
                
                cell.deviceName.text = name;
                
                //Altera o texto da label de cada célula
                if let textLabelText = cell.textLabel {
                    //textLabelText.text = name
                    print(textLabelText)
                }
                
                //Altera a label de detalhe tambem
                if let detailTextLabel = cell.detailTextLabel{
                    //detailTextLabel.text = devicesRSSI[indexPath.row].stringValue
                    print(detailTextLabel)
                }
            }
        }
        
        return cell!
    }
    
    // Evento de toda vez que clicarem em uma célula
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Se estiver pelo menos um dispositvo no vetor (proximo do raio do iPhone)
        if (devices.count > 0){
            
            // Coloca os valores do dicionario em um array
            let discoveredPeripheralArray = Array(devices.values.lazy)
            
            // Pega o valor correspondente do clique no vetor de dispositivos
            peripheralDevice = discoveredPeripheralArray[indexPath.row]
            
            // Delega o disposivo conectado na classe (conecta do dispositivo)
            if let peripheralDevice = peripheralDevice{
                peripheralDevice.delegate = self
                deviceName = peripheralDevice.name!
            }
            else
            {
                deviceName = " "
            }
            
            // Verifica se o dispositivo local é nulo
            if let activeCentralManager = activeCentralManager{
                // Para de procurar outros dispositivos
                activeCentralManager.stopScan()
                
                // Conecta a este dispositvo o clicado anteriormente
                activeCentralManager.connectPeripheral(peripheralDevice!, options: nil)
                if let _ = navigationController{
                    navigationItem.title = "Connecting \(deviceName)"
                }
            }
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        
        self.navigationController?.navigationBar.tintColor = UIColor.grayColor()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
}

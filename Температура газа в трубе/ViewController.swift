//
//  ViewController.swift
//  Температура газа в трубе
//
//  Created by Polynin Pavel on 20.12.15.
//  Copyright © 2015 Polynin Pavel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var TempVhod: UITextField!   
    @IBOutlet weak var ObemRashod: UITextField!
    @IBOutlet weak var DlinaTrubi: UITextField!
    @IBOutlet weak var DiametrTrubi: UITextField!
    @IBOutlet weak var TolshinaStenki: UITextField!
    @IBOutlet weak var SkorostPotokaVodi: UITextField!
    @IBOutlet weak var ContCH4: UITextField!
    
    @IBOutlet weak var Pesult: UILabel!
    
    
    @IBAction func PaschetTemp(sender: UIButton) {
        
        // Функция для задания входного параметра
        func VhodParametr (Text A: UITextField!) -> Double {
            let B = Double(A.text!)
            
            if B != nil {
                return B!
            } else {
                print("Отсутствует значение")
                return 1.0
            }
            
        }
        
        //Входные переменные параметры
        var Temp = VhodParametr(Text: TempVhod) // Температура газа на входе, К
        let RashodGas = VhodParametr(Text: ObemRashod) // Расход газа, м3н/ч
        let VnytreniDiametr = VhodParametr(Text: DiametrTrubi) // Диаметр трубы, м
        let TolzhinaStenki = VhodParametr(Text: TolshinaStenki) // Толщина стенки, м
        let Dlina = VhodParametr(Text: DlinaTrubi) // Длина трубы, м
        let SkorostVodi = VhodParametr(Text: SkorostPotokaVodi) // Скорость потока воды, м/с
        let obemConCH4 = VhodParametr(Text: ContCH4) // Концентрация метана, %
        
        //Постоянные параметры
        let TempStenki: Double = 306 // Температура стенки и воды
        let TeploprovodnosStenki: Double = 47 // Теплопроводность стали, Вт/м*град
        let Pr: Double = 0.66 // Число Прандатля для водорода в диапазоне от 273 до 1273 К
        let PlotnostH2 = 0.08988 //Плотность водорода при нормальных условиях, кг/м3
        let PlotnostCH4 = 0.71 //Плотность метана при нормальных условиях, кг/м3
        var MassiveTemp: [Double] = [] // Массив для набора промежуточных температур, К
        var MassiveTeplo: [Double] = [] //Массив для набора промежуточных теплопотерь, Вт/шаг
        let Shag = 10.0 //(шаг по трубе 0.1 м)
        var Result = "" // Итоговая температура, К
        var TeploviePoteri = 0.0 // Теплопотери, Вт/шаг
        
        //Функция определения теплопроводности от температуры и концентрации метана, Вт/м*град
        func Teploprovodnost (T: Double, C: Double)->Double {
            
            var obResult = 0.0
            var ResultH2 = 0.0
            var ResultCH4 = 0.0
            
            switch T { // Выбор значения теплопроводности H2 и СH4 в зависимости от температуры
            case 273.0..<373.0: ResultH2 = 1.82*pow(10.0, -1.0); ResultCH4 = 3.39*pow(10.0, -2.0)
            case 373.0..<473.0: ResultH2 = 2.18*pow(10.0, -1.0); ResultCH4 = 4.72*pow(10.0, -2.0)
            case 473.0..<573.0: ResultH2 = 2.51*pow(10.0, -1.0); ResultCH4 = 6.10*pow(10.0, -2.0)
            case 573.0..<673.0: ResultH2 = 2.82*pow(10.0, -1.0); ResultCH4 = 7.54*pow(10.0, -2.0)
            case 673.0..<773.0: ResultH2 = 3.12*pow(10.0, -1.0); ResultCH4 = 9.09*pow(10.0, -2.0)
            case 773.0..<873.0: ResultH2 = 3.4*pow(10.0, -1.0); ResultCH4 = 1.07*pow(10.0, -1.0)
            case 873.0..<973.0: ResultH2 = 3.68*pow(10.0, -1.0); ResultCH4 = 1.24*pow(10.0, -1.0)
            case 973.0..<1073.0: ResultH2 = 3.98*pow(10.0, -1.0); ResultCH4 = 1.39*pow(10.0, -1.0)
            case 1073.0..<1173.0: ResultH2 = 4.27*pow(10.0, -1.0); ResultCH4 = 1.54*pow(10.0, -1.0)
            case 1173.0..<1273.0: ResultH2 = 4.56*pow(10.0, -1.0); ResultCH4 = 1.69*pow(10.0, -1.0)
            case 1273.0..<1373.0: ResultH2 = 4.85*pow(10.0, -1.0); ResultCH4 = 1.83*pow(10.0, -1.0)
            case 1373.0..<1473.0: ResultH2 = 5.13*pow(10.0, -1.0); ResultCH4 = 1.97*pow(10.0, -1.0)
            case 1473.0..<1573.0: ResultH2 = 5.41*pow(10.0, -1.0); ResultCH4 = 2.11*pow(10.0, -1.0)
            case 1573.0..<1673.0: ResultH2 = 5.69*pow(10.0, -1.0); ResultCH4 = 2.25*pow(10.0, -1.0)
            case 1673.0..<1773.0: ResultH2 = 5.97*pow(10.0, -1.0); ResultCH4 = 2.38*pow(10.0, -1.0)
            case 1773.0..<1873.0: ResultH2 = 6.24*pow(10.0, -1.0); ResultCH4 = 2.51*pow(10.0, -1.0)
            case 1873.0..<1973.0: ResultH2 = 6.51*pow(10.0, -1.0); ResultCH4 = 2.63*pow(10.0, -1.0)
            case 1973.0..<2073.0: ResultH2 = 6.78*pow(10.0, -1.0); ResultCH4 = 2.75*pow(10.0, -1.0)
            default: print("Температура вне диапазона 273...2073 K")
            }
            
            // Расчет теплопроводности бинарной смеси при условии, что СН4 менее 5% методом Брокау
            if C <= 5.0 && C > 0.0 {
                let q = 0.74
                let x1 = 1.0 - (C/100.0)
                let x2 = C/100.0
                let L1 = x1*ResultH2 + x2*ResultCH4
                let L2 = 1.0/((x1/ResultH2)+(x2/ResultCH4))
                obResult = q*L1 + (1.0-q)*L2} // Содержание метана от 0 до 5%
            else if C == 0.0 {
                obResult = ResultH2} // Содержание метана от 0
            else {print("Концентрация метана вышла за рассчетный диапазон")} // Действие при не попадании в диапазон
            
            return obResult
        }
        
        //Функция определения удельной теплоемкости от температуры и концентрации метана, кДж/Кг*Град
        func Teploemkost (T: Double, C: Double)->Double{
            var obResult = 0.0
            var ResultH2 = 0.0
            var ResultCH4 = 0.0
            
            switch T { // Выбор значения теплоемкости H2 и СH4 в зависимости от температуры
            case 273.0..<373.0: ResultH2 = 28.92/2.0; ResultCH4 = 36.7*0.0625
            case 373.0..<473.0: ResultH2 = 29.16/2.0; ResultCH4 = 42.5*0.0625
            case 473.0..<573.0: ResultH2 = 29.3/2.0; ResultCH4 = 47.8*0.0625
            case 573.0..<673.0: ResultH2 = 29.39/2.0; ResultCH4 = 53.2*0.0625
            case 673.0..<773.0: ResultH2 = 29.48/2.0; ResultCH4 = 58.6*0.0625
            case 773.0..<873.0: ResultH2 = 29.62/2.0; ResultCH4 = 63.97*0.0625
            case 873.0..<973.0: ResultH2 = 29.86/2.0; ResultCH4 = 68.97*0.0625
            case 973.0..<1073.0: ResultH2 = 30.27/2.0; ResultCH4 = 72.98*0.0625
            case 1073.0..<1173.0: ResultH2 = 30.73/2.0; ResultCH4 = 76.34*0.0625
            case 1173.0..<1273.0: ResultH2 = 31.18/2.0; ResultCH4 = 79.39*0.0625
            case 1273.0..<1373.0: ResultH2 = 31.62/2.0; ResultCH4 = 82.3*0.0625
            case 1373.0..<1473.0: ResultH2 = 32.04/2.0; ResultCH4 = 84.6*0.0625
            case 1473.0..<1573.0: ResultH2 = 32.45/2.0; ResultCH4 = 86.8*0.0625
            case 1573.0..<1673.0: ResultH2 = 32.85/2.0; ResultCH4 = 88.8*0.0625
            case 1673.0..<1773.0: ResultH2 = 33.23/2.0; ResultCH4 = 90.6*0.0625
            case 1773.0..<1873.0: ResultH2 = 33.61/2.0; ResultCH4 = 92.1*0.0625
            case 1873.0..<1973.0: ResultH2 = 33.97/2.0; ResultCH4 = 93.5*0.0625
            case 1973.0..<2073.0: ResultH2 = 34.32/2.0; ResultCH4 = 94.77*0.0625
            default: print("Температура вне диапазона 273...2073 K")
            }
            
            let x = C/100 //Доля метана
            let mCH4 = 0.71*x //масса метана в 1 м3
            let mH2 = 0.08988*(1 - x) //масса водорода
            let g1 = mH2/(mCH4+mH2) //Массовая доля водорода
            let g2 = mCH4/(mCH4+mH2) //Массовая доля метана
            
            obResult = g1*ResultH2 + g2*ResultCH4 //Расчет общей теплоемкости смеси
            
            return obResult
        }
        
        //Функция определения кинематической вязкости от температуры и концентрации метана, м2/сек
        func KinViscosity (T: Double, C: Double)->Double{
            var obResult = 0.0
            var ResultH2 = 0.0
            var ResultCH4 = 0.0
            
            switch T { // Выбор значения вязкости H2 и СH4 в зависимости от температуры
            case 273.0..<373.0: ResultH2 = 1.24*pow(10.0, -4.0); ResultCH4 = 2.01*pow(10.0, -5.0)
            case 373.0..<473.0: ResultH2 = 1.94*pow(10.0, -4.0); ResultCH4 = 3.26*pow(10.0, -5.0)
            case 473.0..<573.0: ResultH2 = 2.75*pow(10.0, -4.0); ResultCH4 = 4.72*pow(10.0, -5.0)
            case 573.0..<673.0: ResultH2 = 3.67*pow(10.0, -4.0); ResultCH4 = 6.37*pow(10.0, -5.0)
            case 673.0..<773.0: ResultH2 = 4.69*pow(10.0, -4.0); ResultCH4 = 8.2*pow(10.0, -5.0)
            case 773.0..<873.0: ResultH2 = 5.81*pow(10.0, -4.0); ResultCH4 = 1.02*pow(10.0, -4.0)
            case 873.0..<973.0: ResultH2 = 7.01*pow(10.0, -4.0); ResultCH4 = 1.24*pow(10.0, -4.0)
            case 973.0..<1073.0: ResultH2 = 8.31*pow(10.0, -4.0); ResultCH4 = 1.47*pow(10.0, -4.0)
            case 1073.0..<1173.0: ResultH2 = 9.69*pow(10.0, -4.0); ResultCH4 = 1.71*pow(10.0, -4.0)
            case 1173.0..<1273.0: ResultH2 = 1.11*pow(10.0, -3.0); ResultCH4 = 1.98*pow(10.0, -4.0)
            case 1273.0..<1373.0: ResultH2 = 1.27*pow(10.0, -3.0); ResultCH4 = 2.25*pow(10.0, -4.0)
            case 1373.0..<1473.0: ResultH2 = 1.43*pow(10.0, -3.0); ResultCH4 = 2.54*pow(10.0, -4.0)
            case 1473.0..<1573.0: ResultH2 = 1.6*pow(10.0, -3.0); ResultCH4 = 2.84*pow(10.0, -4.0)
            case 1573.0..<1673.0: ResultH2 = 1.78*pow(10.0, -3.0); ResultCH4 = 3.15*pow(10.0, -4.0)
            case 1673.0..<1773.0: ResultH2 = 1.96*pow(10.0, -3.0); ResultCH4 = 3.48*pow(10.0, -4.0)
            case 1773.0..<1873.0: ResultH2 = 2.15*pow(10.0, -3.0); ResultCH4 = 3.82*pow(10.0, -4.0)
            case 1873.0..<1973.0: ResultH2 = 2.35*pow(10.0, -3.0); ResultCH4 = 4.17*pow(10.0, -4.0)
            case 1973.0..<2073.0: ResultH2 = 2.55*pow(10.0, -3.0) ; ResultCH4 = 4.54*pow(10.0, -4.0)
            default: print("Температура вне диапазона 273...2073 K")
            }
            
            let x = C/100 //Доля метана
            obResult = pow(ResultH2, (1.0-x))*pow(ResultCH4, x) //Расчет вязкости смеси
            
            return obResult
        }
        
        
        //Функция определения скорости потока газа от температуры, м/с
        func SkorostGasa (G: Double, T: Double, D: Double)->Double {
            
            let V = (4.0*G*T)/(3600.0*273.0*3.14*pow(D, 2))
            
            return V
        }
        
        //Функция определения коэффициента теплоотдачи от стенки к воде (от скорости потока воды), Вт/м2*К
        func TeploodachaVodi (V: Double)->Double {
            var L = 0.0
            L = 350.0 + 2100.0*sqrt(V)
            return L
        }
        
        //Функция определения массового расхода потока газа, кг/с
        func MassRashodGas (G: Double, PH2: Double, PCH4: Double, C: Double) ->Double{
            let x = C/100 //Доля метана
            let P = ((PlotnostCH4*x)+(PlotnostH2*(1.0-x)))/1.0 //Плотность смеси
            let KgPerSec = (G*P)/3600.0
            return KgPerSec
        }
        
        //Основной цикл расчета изменения Температуры газа с шагом...
        
        for var i=0.0; i<=Shag*Dlina; i++ {
            
            if Temp >= TempStenki {
                
                //Расчет числа Ренольдса от температуры
                
                let Re: Double = (SkorostGasa(RashodGas, T: Temp, D: VnytreniDiametr)*VnytreniDiametr)/(KinViscosity(Temp, C: obemConCH4))
                
                //Выбор уравнения для расчета Нуссельта в зависимости от значения Рейнольдса
                
                if Re <= 2000.0 {
                    
                    let Nu = 0.33*pow(Re, 0.5)*pow(Pr, 0.43) //Расчет Нуссельта
                    
                    let Teplootdacha: Double = (Nu*Teploprovodnost(Temp, C: obemConCH4))/(VnytreniDiametr) // Расчет коэффициента теплоотдачи, Вт/м2*К
                    let Peremen1: Double = (VnytreniDiametr+TolzhinaStenki)/VnytreniDiametr //Переменная для логарифма
                    let ObobKoeffTeplootdachi = 1.0/((1.0/(Teplootdacha*VnytreniDiametr))+((log(Peremen1))/(2.0*TeploprovodnosStenki))+(1.0/(TeploodachaVodi(SkorostVodi)*(VnytreniDiametr+TolzhinaStenki)))) // Расчет обобщенного коэффициента теплоотдачи
                    let TeplovoiPotok = 3.14*ObobKoeffTeplootdachi*(Temp-TempStenki) // Тепловой поток от температуры газа, Вт/м трубы
                    TeploviePoteri = TeplovoiPotok*(1/Shag) // Тепловой поток от температуры газа, Вт/шаг трубы
                    let NewTemp = ((Temp*Teploemkost(Temp, C: obemConCH4)*1000.0*MassRashodGas(RashodGas, PH2: PlotnostH2, PCH4: PlotnostCH4, C: obemConCH4))-TeploviePoteri)/(Teploemkost(Temp, C: obemConCH4)*1000.0*MassRashodGas(RashodGas, PH2: PlotnostH2, PCH4: PlotnostCH4, C: obemConCH4))
                    // Температура газа после прохождения участка длинной с (1/Шаг метров), К
                    
                    Temp = NewTemp // Присвоение новой температуры в замен старой
                    
                    
                } //Ламинарный поток
                else {
                    
                    let Nu = 0.021*pow(Re, 0.8)*pow(Pr, 0.43) //Расчет Нуссельта
                    
                    let Teplootdacha: Double = (Nu*Teploprovodnost(Temp, C: obemConCH4))/(VnytreniDiametr) // Расчет коэффициента теплоотдачи, Вт/м2*К
                    let Peremen1: Double = (VnytreniDiametr+TolzhinaStenki)/VnytreniDiametr //Переменная для логарифма
                    let ObobKoeffTeplootdachi = 1.0/((1.0/(Teplootdacha*VnytreniDiametr))+((log(Peremen1))/(2.0*TeploprovodnosStenki))+(1.0/(TeploodachaVodi(SkorostVodi)*(VnytreniDiametr+TolzhinaStenki)))) // Расчет обобщенного коэффициента теплоотдачи
                    let TeplovoiPotok = 3.14*ObobKoeffTeplootdachi*(Temp-TempStenki) // Тепловой поток от температуры газа, Вт/м трубы
                    TeploviePoteri = TeplovoiPotok*(1/Shag) // Тепловой поток от температуры газа, Вт/шаг трубы
                    let NewTemp = ((Temp*Teploemkost(Temp, C: obemConCH4)*1000.0*MassRashodGas(RashodGas, PH2: PlotnostH2, PCH4: PlotnostCH4, C: obemConCH4))-TeploviePoteri)/(Teploemkost(Temp, C: obemConCH4)*1000.0*MassRashodGas(RashodGas, PH2: PlotnostH2, PCH4: PlotnostCH4, C: obemConCH4))
                    // Температура газа после прохождения участка длинной с (1/Шаг метров), К
                    
                    Temp = NewTemp // Присвоение новой температуры в замен старой
                    
                    
                } //Турбулентный поток
                
                MassiveTeplo += [TeploviePoteri] // Запись всех промежуточных теплопотерь в массив
                MassiveTemp += [Temp] // Запись всех промежуточных температур в массив
                
                //Вывод значения температуры в виде строки
                let FinTemp: Int = Int(MassiveTemp[MassiveTemp.count-1])
                Result = "\(FinTemp - 273) C"
                
            }
            else {Result = "\(Int(TempStenki) - 273) C"} //Действия программы при остывании газа до температуры стенки
        }
        
        let KonTemp = Result // Конечная температура газа
        
        Pesult.text = "\(KonTemp)"
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


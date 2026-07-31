import {defineStore} from 'pinia'

const asideStore = defineStore('aside',{
    state: () => {
        return{
            //隐藏、显示项目tree列表
            editingModel: false,
            //项目列表数据
            projTreeList: [],
            //当前选择的项目id
            currentProjId: 0,
        }
    },
    getters:{

    },
    actions:{
        disableEditingModel(){
            this.editingModel = false 
        },
        enableEditingModel(){
            this.editingModel = true
        },
        setProjTreeList(projTreeList:[]){
            this.projTreeList = projTreeList
        },
        setCurrentProjId(currentProjId:any){
            this.currentProjId = currentProjId
        }
        
    }
})

export default asideStore
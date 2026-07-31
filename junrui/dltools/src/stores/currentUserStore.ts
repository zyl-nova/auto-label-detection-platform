import {defineStore} from 'pinia'

const currentUserSotre = defineStore('currentUser',{
    state: () => {
        return{
            //当前登录用户的id
            currentUserId: 0,
            //当前用户名字
            currentUserName: ''
        }
    },
    getters:{
        
    },
    actions:{
        setCurrentUserId(id:number){
            this.currentUserId = id
        },
        setCurrentUserName(currentUserName:string){
            this.currentUserName = currentUserName
        },
        
    }
})

export default currentUserSotre
import SidebarWithHeader from "./components/shared/SideBar.jsx";
import {Text} from "@chakra-ui/react";

const Home = () => {

    return (
        <SidebarWithHeader>
            <Text fontSize={"4xl"}>Dashboard</Text>
            <Text fontSize={"2xl"}>Welcome to the learner management system</Text>
        </SidebarWithHeader>
    )
}

export default Home;
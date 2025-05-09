import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/common/helpers/is_dark_mode.dart';
import 'package:spotify_clone/common/widgets/appbar/app_bar.dart';
import 'package:spotify_clone/common/widgets/favorite_button/favorite_button.dart';
import 'package:spotify_clone/core/configs/constants/app_urls.dart';
import 'package:spotify_clone/domain/usecases/auth/logout.dart';
import 'package:spotify_clone/presentation/auth/pages/signin.dart';
import 'package:spotify_clone/presentation/profile/bloc/favorite_songs_cubit.dart';
import 'package:spotify_clone/presentation/profile/bloc/favorite_songs_state.dart';
import 'package:spotify_clone/presentation/profile/bloc/profile_info_cubit.dart';
import 'package:spotify_clone/presentation/profile/bloc/profile_info_state.dart';
import 'package:spotify_clone/presentation/song_player/pages/song_player.dart';

import '../../../service_locator.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18
          ),
        ),
      ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _profileInfo(context),
                const SizedBox(height: 30),
                _favoriteSongs(),
                const SizedBox(height: 20),
                _logoutButton(context),
              ],
            ),
          ),
        ),
    );
  }

  Widget _logoutButton(BuildContext context){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
            onPressed: () async {
              final logoutUseCase = sl.get<LogoutUseCase>();
              final result = await logoutUseCase.execute();
              result.fold(
                  (failure){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          failure.toString(),
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      )
                    );
                  },
                  (success){
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => SigninPage()),
                          (route) => false,
                    );
                  }
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(
                vertical: 16
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)
              ),
            ),
            child: const Text(
              "Log Out",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
            )
        )
      )
    );
  }

  Widget _profileInfo(BuildContext context){
    return BlocProvider(
      create: (context) => ProfileInfoCubit()..getUser(),
      child: Container(
        height: MediaQuery.of(context).size.height / 3.2,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.isDarkMode ? const Color(0xff2c2b2b) : Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          )
        ),
        child: BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
          builder: (context, state) {
            if (state is ProfileInfoLoading){
              return Container(
                alignment: Alignment.center,
                child: Center(
                  child: const CircularProgressIndicator(),
                )
              );
            } else if (state is ProfileInfoLoaded){
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                          state.userEntity.imageURL!
                        )
                      )
                    ),
                  ),
                  const SizedBox(height: 15,),
                  Text(
                    state.userEntity.email!
                  ),
                  const SizedBox(height: 10,),
                  Text(
                    state.userEntity.fullName!,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold
                    ),
                  )
                ],
              );
            }
            return Container(
              child: Text(
                "Can't loading..."
              )
            );
          },
        ),
      ),
    );
  }

  Widget _favoriteSongs() {
    return SingleChildScrollView(
      child: BlocProvider(
        create: (context) => FavoriteSongsCubit()..getFavoriteSongs(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FAVORITE SONGS',
              ),
      
              const SizedBox(
                height: 20,
              ),
                BlocBuilder<FavoriteSongsCubit,FavoriteSongsState>(
                  builder: (context,state) {
                    if(state is FavoriteSongsLoading) {
                      return const CircularProgressIndicator();
                    }
                    if(state is FavoriteSongsLoaded) {
                      return ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) => SongPlayerPage(songEntity: state.favoriteSongs[index])
                                    )
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 70,
                                        width: 70,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    '${AppURLs.coverFirestorage}${state.favoriteSongs[index].artist} - ${state.favoriteSongs[index].title}.jpg?${AppURLs.mediaAlt}'
                                                )
                                            )
                                        ),
                                      ),
                
                                      const SizedBox(width: 10, ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            state.favoriteSongs[index].title,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16
                                            ),
                                          ),
                                          const SizedBox(height: 5, ),
                                          Text(
                                            state.favoriteSongs[index].artist,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 11
                                            ),
                                          ),
                                        ],
                                      )
                
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                          state.favoriteSongs[index].duration.toString().replaceAll('.', ':')
                                      ),
                                      const SizedBox(width: 20, ),
                                      FavoriteButton(
                                        songEntity: state.favoriteSongs[index],
                                        key: UniqueKey(),
                                        function: (){
                                          context.read<FavoriteSongsCubit>().removeSong(index);
                                        },
                                      )
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => const SizedBox(height: 20,),
                          itemCount: state.favoriteSongs.length
                      );
                    }
                    if(state is FavoriteSongsFailure) {
                      return const Text(
                          'Please try again.'
                      );
                    }
                    return Container();
                  } ,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

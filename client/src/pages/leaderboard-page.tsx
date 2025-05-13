import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { 
  Tabs, 
  TabsList, 
  TabsTrigger,
  TabsContent 
} from '@/components/ui/tabs';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Skeleton } from '@/components/ui/skeleton';
import { 
  Search, 
  Trophy, 
  Medal, 
  Award,
  Users
} from 'lucide-react';
import { 
  Avatar, 
  AvatarFallback, 
  AvatarImage 
} from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';

interface LeaderboardUser {
  id: number;
  username: string;
  displayName?: string;
  profileImage?: string;
  points: number;
  correctPredictions: number;
  totalMatches: number;
}

const LeaderboardPage = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [timeframe, setTimeframe] = useState('all-time');
  
  // Fetch leaderboard data
  const { data: leaderboard, isLoading } = useQuery<LeaderboardUser[]>({
    queryKey: ['/api/leaderboard', timeframe],
    queryFn: async () => {
      const res = await fetch(`/api/leaderboard?timeframe=${timeframe}`);
      if (!res.ok) throw new Error('Failed to fetch leaderboard');
      return res.json();
    },
  });
  
  const filteredUsers = () => {
    if (!leaderboard) return [];
    
    if (!searchTerm) return leaderboard;
    
    const term = searchTerm.toLowerCase();
    return leaderboard.filter(user => 
      user.username.toLowerCase().includes(term) || 
      (user.displayName && user.displayName.toLowerCase().includes(term))
    );
  };
  
  const getAccuracy = (user: LeaderboardUser) => {
    if (user.totalMatches === 0) return '0%';
    const accuracy = Math.round((user.correctPredictions / user.totalMatches) * 100);
    return `${accuracy}%`;
  };
  
  const getPositionStyle = (position: number) => {
    if (position === 1) {
      return { 
        icon: <Trophy className="h-5 w-5 text-yellow-500" />, 
        textStyle: 'text-yellow-600 font-bold'
      };
    } else if (position === 2) {
      return { 
        icon: <Medal className="h-5 w-5 text-neutral-400" />, 
        textStyle: 'text-neutral-600 font-bold' 
      };
    } else if (position === 3) {
      return { 
        icon: <Award className="h-5 w-5 text-amber-700" />, 
        textStyle: 'text-amber-800 font-bold' 
      };
    }
    return { icon: null, textStyle: 'text-neutral-600' };
  };
  
  const renderSkeletonRows = () => {
    return Array.from({ length: 10 }).map((_, i) => (
      <TableRow key={i}>
        <TableCell className="py-3">
          <Skeleton className="h-6 w-6 rounded-full" />
        </TableCell>
        <TableCell>
          <div className="flex items-center gap-3">
            <Skeleton className="h-8 w-8 rounded-full" />
            <Skeleton className="h-4 w-32" />
          </div>
        </TableCell>
        <TableCell>
          <Skeleton className="h-4 w-16" />
        </TableCell>
        <TableCell>
          <Skeleton className="h-4 w-16" />
        </TableCell>
        <TableCell>
          <Skeleton className="h-4 w-16" />
        </TableCell>
      </TableRow>
    ));
  };
  
  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <h1 className="text-3xl font-bold mb-6 font-heading">Leaderboard</h1>
      
      <div className="bg-white shadow-md rounded-lg p-4 mb-8">
        <div className="flex flex-col md:flex-row justify-between gap-4 mb-6">
          <div className="relative w-full md:w-1/3">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-neutral-400" size={18} />
            <Input
              type="text"
              placeholder="Search users..."
              className="pl-10"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
          
          <Tabs defaultValue="all-time" value={timeframe} onValueChange={setTimeframe} className="w-full md:w-auto">
            <TabsList>
              <TabsTrigger value="all-time">All Time</TabsTrigger>
              <TabsTrigger value="monthly">Monthly</TabsTrigger>
              <TabsTrigger value="weekly">Weekly</TabsTrigger>
            </TabsList>
          </Tabs>
        </div>
        
        {isLoading ? (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-16 text-center">Rank</TableHead>
                <TableHead>User</TableHead>
                <TableHead>Points</TableHead>
                <TableHead className="hidden md:table-cell">Predictions</TableHead>
                <TableHead className="hidden md:table-cell">Accuracy</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {renderSkeletonRows()}
            </TableBody>
          </Table>
        ) : filteredUsers().length > 0 ? (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-16 text-center">Rank</TableHead>
                <TableHead>User</TableHead>
                <TableHead>Points</TableHead>
                <TableHead className="hidden md:table-cell">Predictions</TableHead>
                <TableHead className="hidden md:table-cell">Accuracy</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredUsers().map((user, index) => {
                const position = index + 1;
                const { icon, textStyle } = getPositionStyle(position);
                
                return (
                  <TableRow key={user.id} className={position <= 3 ? 'bg-neutral-50' : ''}>
                    <TableCell className="font-medium text-center">
                      {icon || (
                        <span className={textStyle}>{position}</span>
                      )}
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <Avatar>
                          <AvatarImage src={user.profileImage} alt={user.username} />
                          <AvatarFallback className="bg-primary text-white">
                            {user.displayName?.[0] || user.username[0]}
                          </AvatarFallback>
                        </Avatar>
                        <div>
                          <div className="font-medium">{user.displayName || user.username}</div>
                          {user.displayName && (
                            <div className="text-sm text-neutral-500">@{user.username}</div>
                          )}
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline" className="font-semibold text-primary border-primary">
                        {user.points} pts
                      </Badge>
                    </TableCell>
                    <TableCell className="hidden md:table-cell">
                      {user.correctPredictions} / {user.totalMatches}
                    </TableCell>
                    <TableCell className="hidden md:table-cell">
                      <span className="font-medium">{getAccuracy(user)}</span>
                    </TableCell>
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>
        ) : (
          <div className="text-center py-12 text-neutral-500 border border-dashed rounded-md">
            <Users className="mx-auto h-12 w-12 text-neutral-300 mb-2" />
            <h3 className="text-lg font-medium text-neutral-700 mb-1">No users found</h3>
            <p>Try adjusting your search terms</p>
          </div>
        )}
      </div>
      
      <div className="bg-white shadow-md rounded-lg p-6">
        <h2 className="text-xl font-bold mb-4">How Points are Earned</h2>
        <div className="space-y-3">
          <div className="flex items-start gap-3">
            <div className="bg-green-100 p-2 rounded-full mt-0.5">
              <Trophy className="h-5 w-5 text-green-600" />
            </div>
            <div>
              <h3 className="font-semibold text-lg">Match Winner Prediction</h3>
              <p className="text-neutral-600">+1 point for correctly predicting the match winner</p>
            </div>
          </div>
          
          <div className="flex items-start gap-3">
            <div className="bg-blue-100 p-2 rounded-full mt-0.5">
              <Medal className="h-5 w-5 text-blue-600" />
            </div>
            <div>
              <h3 className="font-semibold text-lg">Toss Winner Prediction</h3>
              <p className="text-neutral-600">+1 point for correctly predicting the toss winner</p>
            </div>
          </div>
          
          <div className="border-t border-neutral-200 pt-3 mt-3">
            <p className="text-neutral-600 text-sm">
              Leaderboards are updated in real-time when match results are posted. Rankings are determined by total points, 
              with ties broken by the number of correct predictions.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default LeaderboardPage;